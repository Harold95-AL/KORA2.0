"""Regenera SpriteFrames a partir de las hojas y el manifiesto; Python 3, sin dependencias.

Uso desde la raíz: python tools/import_sprites.py
Esto reemplaza resources/player/player_frames.tres. Para editar fotogramas a mano,
usar el editor Godot y no ejecutar de nuevo este generador.
"""
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]


def main():
    manifest = json.loads((ROOT / "data/player_animations.json").read_text(encoding="utf-8"))
    width, height = manifest["frame_size"]
    animations = manifest["animations"]
    count = sum(item["frames"] for item in animations)
    lines = [f'[gd_resource type="SpriteFrames" load_steps={count + len(animations) + 1} format=3]', ""]
    placeholder_resources = []
    layouts = {}
    for index, item in enumerate(animations):
        path = f'assets/sprites/player/male_hero-{item["name"]}.png'
        if item.get("placeholder"):
            for frame in range(item["frames"]):
                placeholder_resources.extend([f'[sub_resource type="PlaceholderTexture2D" id="{item["name"]}_{frame}"]', f'size = Vector2({width}, {height})'])
            continue
        header = (ROOT / path).read_bytes()[:24]
        if header[:8] != b'\x89PNG\r\n\x1a\n':
            raise ValueError(f"PNG inválido: {path}")
        dimensions = struct.unpack(">II", header[16:24])
        if dimensions[0] % width != 0 or dimensions[1] % height != 0:
            raise ValueError(f"Dimensiones inesperadas: {path}: {dimensions}")
        columns = dimensions[0] // width
        rows = dimensions[1] // height
        if columns * rows != item["frames"]:
            raise ValueError(f"Dimensiones inesperadas: {path}: {dimensions} para {item['frames']} celdas")
        layouts[item["name"]] = (columns, rows)
        lines.append(f'[ext_resource type="Texture2D" path="res://{path}" id="{index + 1}"]')
    for index, item in enumerate(animations):
        for frame in range(item["frames"]):
            if item.get("placeholder"):
                continue
            columns, rows = layouts[item["name"]]
            lines.extend([
                "", f'[sub_resource type="AtlasTexture" id="{item["name"]}_{frame}"]',
                f'atlas = ExtResource("{index + 1}")',
                f'region = Rect2({(frame % columns) * width}, {(frame // columns) * height}, {width}, {height})'
            ])
    if placeholder_resources:
        lines.extend(["", *placeholder_resources])
    lines.extend(["", "[resource]", "animations = ["])
    for index, item in enumerate(animations):
        frames = ", ".join('{"duration": 1.0, "texture": SubResource("' + item["name"] + f'_{frame}' + '")}' for frame in range(item["frames"]))
        lines.extend([
            '{"frames": [' + frames + '],',
            '"loop": ' + str(item["loop"]).lower() + ',',
            f'"name": &"{item["name"]}", "speed": {float(item["fps"])}' + '}' + ("," if index < len(animations) - 1 else "")
        ])
    lines.extend([
        "]", ""
    ])
    destination = ROOT / "resources/player/player_frames.tres"
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text("\n".join(lines), encoding="utf-8")
    print(f"OK: {len(animations)} animaciones, {count} fotogramas. {destination}")


if __name__ == "__main__":
    main()

