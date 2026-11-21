"""Autoría inicial del boceto. Genera escenas NATIVAS editables y los datos.

No se ejecuta al jugar. Volver a ejecutarlo reemplaza los niveles y JSON generados;
guardar antes cualquier edición manual de esos archivos.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def write(path, text):
    destination = ROOT / path
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(text, encoding="utf-8")


def gd(value):
    if isinstance(value, bool):
        return str(value).lower()
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, tuple):
        return "Vector2(%s, %s)" % value
    if isinstance(value, list):
        return "PackedStringArray(" + ", ".join(gd(v) for v in value) + ")"
    return str(value)


def narrative():
    entries = {}

    def entry(key, title, lines, blocking=False):
        entries[key] = dict(title=title, lines=lines, blocking=blocking)

    entry("STORY_01", "Después del impacto", ["LUMA: Propulsión destruida. Seguimos operativos. Busca la terminal de navegación."], False)
    entry("STORY_02", "Telemetría recuperada", ["LUMA: La nave recibió una descarga dirigida desde la superficie. La señal nos atrajo, pero no causó el accidente.", "EXPLORADOR: Entonces busquemos energía y averigüemos quién construyó esas estructuras."], True)
    entry("STORY_03", "SIL / Primer contacto", ["SIL: ¡Tii-rii!", "LUMA: Patrón de comunicación detectado. Asignaré el identificador SIL. Parece interesado en tus movimientos."])
    entry("STORY_04", "Bajo la superficie", ["LUMA: La señal aumenta bajo nuestros pies. El resonador marca un camino hacia la grieta.", "EXPLORADOR: No estamos siguiendo una voz. Estamos siguiendo un planeta."], True)
    entry("STORY_05", "La Resonancia", ["LUMA: Los cristales transportan energía e información. El pilar está conectado a los organismos cercanos.", "EXPLORADOR: Tomaremos solo lo necesario. No vamos a apagar lo que vive aquí."], True)
    entry("STORY_06", "El santuario responde", ["LUMA: La energía vuelve a los jardines. Los Eshar construyeron el santuario sobre esta red natural.", "SIL: Tii... / La pequeña criatura se queda fuera de las ruinas."])
    entry("STORY_07", "Ayen / El nombre KORA", ["AYEN: El planeta conservaba pequeñas huellas de cada ser que había vivido sobre él. Escucharlas nos cambió para siempre.", "LUMA: KORA: aquello que mantiene unidos los recuerdos de la vida. Los Eshar estudiaban memoria y tiempo.", "INSCRIPCIÓN: Recordar no es detener el tiempo. Quien retiene todo impide que algo nuevo comience."], True)
    entry("STORY_08", "ORÚ / Autorización", ["ORÚ: Protocolo interrumpido. Acceso autorizado. Registro encontrado... registro aún no generado.", "LUMA: Reconoce una firma nuestra que todavía no existe en sus archivos. El descenso está abierto."], True)
    entry("STORY_09", "Las profundidades", ["LUMA: Estas pulsaciones recorren una red planetaria. Las sobrecargas alternan reposo, aviso y descarga.", "EXPLORADOR: Esperaremos la calma antes de cruzar."])
    entry("STORY_10", "Proyecto Vigilia", ["ARCHIVO: Preservar patrones de memoria y conciencia ante una crisis astronómica. Estado inicial: compatible.", "LUMA: Los Eshar intentaron conservar a su civilización. Estas cámaras mantienen fragmentos conscientes en repetición."], True)
    entry("STORY_11", "La advertencia de Ayen", ["AYEN: Cada memoria estable requiere energía que ya no llega al ecosistema. Solicité suspender Vigilia. La propuesta fue rechazada.", "LUMA: Aumentaron la extracción. La sobrecarga fragmentó las memorias y agotó el planeta: la Fractura no es una infección."], True)
    entry("STORY_12", "El sacrificio de Saren", ["SAREN: Una conciencia conectada podría adaptar las defensas y evitar la propagación.", "AYEN: Podrías quedar atrapado. / SAREN: Entonces tendrás que encontrar la manera de liberarme.", "LUMA: Su sacrificio contuvo la Fractura. Cuatro siglos después, solo parece recordar la orden de proteger el núcleo."], True)
    entry("STORY_13", "Eco en el conducto", ["VOZ: Sigue... la luz... Estoy aquí.", "LUMA: Coincidencia acústica detectada. Suena como tú."], True)
    entry("STORY_14", "El corazón de KORA", ["LUMA: Los estabilizadores permiten entrar. La energía aún converge en el núcleo.", "EXPLORADOR: Ya no buscamos solo una forma de regresar. Tenemos que detener la extracción."])
    entry("STORY_15", "El Eco de Fase", ["LUMA: La señal se originará aquí. Todavía no ha sido enviada. El Eco de Fase refleja información limitada hacia un estado anterior de la Resonancia.", "EXPLORADOR: Nuestra propia transmisión nos trajo hasta KORA. / LUMA: Y nuestra aproximación activó la descarga defensiva.", "LUMA: No permite transportar cuerpos ni objetos. Esta ventana de sincronización es excepcional."], True)
    entry("STORY_16", "Saren / La última puerta", ["SAREN: He esperado. El sistema preserva lo que queda. No permitiré otra pérdida.", "EXPLORADOR: El planeta está muriendo. No puedes seguir protegiendo una puerta para siempre."], True)
    entry("STORY_17", "Liberación de las memorias", ["Las voces dejan de repetirse. Los ecos conscientes se dispersan con calma. La energía regresa a la Resonancia.", "LUMA: El almacenamiento permanente está desactivado. La ventana del transmisor de fase se ha abierto."], True)
    entry("STORY_18", "La señal / El ciclo se completa", ["LUMA: Enviarás la señal que recibimos antes de llegar. Conoces las consecuencias.", "EXPLORADOR: También conozco lo que encontramos después. Sigue la señal. Sigue la luz. No apagues el corazón. Estoy aquí.", "Una pulsación corta. Una larga. Una corta. El mensaje desaparece hacia el pasado."], True)
    entry("STORY_19", "Núcleo estabilizado", ["SAREN: Había olvidado cómo se veía la luz sin una puerta delante.", "LUMA: Flujo energético estable. La recuperación llevará tiempo. / EXPLORADOR: Pero ahora podrán vivir."], True)
    entry("STORY_20", "Otra señal", ["LUMA: Nueva transmisión detectada. Mismo patrón. El origen está fuera de este sistema.", "EXPLORADOR: Entonces tenemos algo que investigar."], True)
    extra = {
        "CELL": ("Energía portátil", ["LUMA: La célula no reparará la nave, pero alimentará tu equipo. Algo salió ligeramente bien."], False),
        "LOOKOUT": ("Mirador", ["EXPLORADOR: Hay estructuras entre los árboles. / LUMA: Conviene averiguar quién las construyó."], False),
        "SAMPLE": ("Una muestra, no una herida", ["LUMA: Extracción limitada completada. El flujo que alimenta a los organismos permanece estable."], False),
        "SIL_RETURN": ("SIL vuelve", ["SIL: ¡Tii-rii! / LUMA: Nos muestra un jardín debilitado. La energía llega a otras regiones, pero aquí casi se ha detenido."], False),
        "PUZZLE_CLUE": ("Inscripción de los tres pilares", ["La inscripción muestra: I → III → II. Activa los tres resonadores en ese orden.", "Si te equivocas, la secuencia se reinicia sin daño. Los símbolos permanecerán visibles."], True),
        "PUZZLE_DONE": ("Secuencia estable", ["LUMA: Enlace establecido. La cámara de Ayen puede abrirse."], False),
        "ORU_INTRO": ("ORÚ / Protocolo de acceso", ["ORÚ: Entidad no reconocida. Registro encontrado. Registro aún no generado.", "LUMA: El escudo se apaga después de cada ataque. Retrocede ante el arco amarillo y salta las ondas."], True),
        "RESCUE": ("Una vida fuera del ciclo", ["La compuerta se abre y la criatura debilitada escapa de la descarga.", "LUMA: El deterioro de la Resonancia está afectando al ecosistema. Podemos reducirlo desde el regulador."], False),
        "REGULATOR": ("Sobrecarga reducida", ["LUMA: Regulador activo. Los peligros de esta zona se han apagado, pero la extracción central sigue funcionando."], False),
        "TRANSMISSIONS": ("Historial de transmisiones", ["LUMA: No existe un emisor registrado en el momento de nuestra llegada. Sin embargo, la señal existe dentro del sistema."], True),
        "REDIRECT": ("Ruta al núcleo", ["LUMA: Energía redirigida. El complejo se deteriora, pero hay una ruta segura de mantenimiento hacia las profundidades."], False),
        "DESCENT": ("Descenso de mantenimiento", ["LUMA: El ascensor principal falla. Usa los descansos laterales. Antes de bajar puedes ver la siguiente plataforma."], False),
        "CONDUIT": ("Conducto de emergencia", ["LUMA: Parte de la energía regresa al ecosistema. Aún debemos desconectar la extracción central."], False),
        "AYEN_LAST": ("La última grabación de Ayen", ["AYEN: Los ecos no pueden regresar a la vida. Solo repiten fragmentos de quienes fuimos. El planeta necesita recuperar su energía.", "AYEN: Si encuentras a Saren, recuerda que no siempre fue un guardián."], True),
        "CORE_CONSOLE": ("La decisión", ["LUMA: Restaurar la Resonancia exige desactivar el almacenamiento permanente. Los ecos desaparecerán como patrones conscientes.", "EXPLORADOR: Ayen dejó instrucciones para liberarlos. Saren prometió custodiar el sistema hasta que eso fuera posible."], True),
        "SAREN_DEFEAT": ("La promesa", ["SAREN: Creí que podía protegerlos. ¿Qué ocurrirá conmigo?", "LUMA: Tu conciencia está vinculada a la contención. No podrá mantenerse después de la liberación.", "SAREN: Entonces... por fin podré descansar. Ayen... abre la puerta."], True),
    }
    for key, (title, lines, blocking) in extra.items():
        entry(key, title, lines, blocking)
    records = {
        "REG_01": ("01 / La primera expedición Eshar", "No encontramos la Resonancia. Nacimos rodeados de ella. Durante generaciones confundimos sus sonidos con el viento."),
        "REG_02": ("02 / La memoria", "La memoria no es únicamente aquello que conservamos. También es aquello que transformamos al continuar viviendo."),
        "REG_03": ("03 / Proyecto Vigilia", "Objetivo: preservar patrones conscientes durante la crisis astronómica. Estado inicial: compatible. Consumo energético: superior a lo previsto."),
        "REG_04": ("04 / La advertencia", "AYEN: El sistema de extracción ha superado el límite recomendado. La continuidad de Vigilia amenaza la estabilidad de la Resonancia. Solicito suspensión inmediata."),
        "REG_05": ("05 / Protocolo Saren", "La contención permanecerá activa hasta que una entidad externa consiga restablecer la distribución energética. Prioridad: evitar propagación."),
        "REG_06": ("06 / Una última anotación", "AYEN: Si nuestro mundo vuelve a florecer algún día, quizá nadie recuerde nuestros nombres. Después de todo lo ocurrido, empiezo a pensar que eso sería suficiente."),
        "REG_SIGNAL": ("Fragmento / Tres pulsaciones", "El cristal repite el patrón de la transmisión: corta, larga, corta. La señal utiliza la Resonancia."),
        "REG_VOICE": ("Fragmento / Una voz sin cuerpo", "Una voz surge de la piedra. No hay nadie cerca. El cristal conserva la huella de un ser que vivió aquí."),
        "REG_INSCRIPTION": ("Inscripción / La red", "La memoria no pertenece a una sola piedra. El pulso atraviesa el mundo. El resto de la inscripción se ha perdido."),
    }
    for key, (title, text) in records.items():
        entry(key, title, [text], True)
    entries["PROLOGUE"] = {"pages": [
        {"title": "PRÓLOGO / LA SEÑAL", "text": "Una exploración de rutina. Un planeta sin registrar.\nTres pulsaciones: corta, larga, corta."},
        {"title": "Una marca temporal imposible", "text": "LUMA: La transmisión está fechada treinta y una horas después de nuestra recepción.\nVOZ: Sigue... la luz... No apagues... Estoy aquí."},
        {"title": "Aproximación", "text": "EXPLORADOR: Si alguien está pidiendo ayuda, debemos intentarlo.\nLUMA: Probabilidad de que sea una decisión prudente: baja."},
        {"title": "Descarga / Impacto", "text": "La defensa automática de la superficie alcanza la nave.\nLUMA: Navegación desconectada. Protección de emergencia activada.\nSilencio. Después, una voz: ¿Me recibes?"},
    ]}
    entries["EPILOGUE"] = {"pages": [
        {"title": "EPÍLOGO / EL ÚLTIMO PULSO", "text": "Los cristales recuperan una luz estable. La vegetación vuelve a crecer.\nLUMA: El proceso llevará mucho tiempo.\nEXPLORADOR: Pero ahora lo tienen."},
        {"title": "Una pequeña despedida", "text": "SIL: ¡Tii-rii!\nLa criatura gira alrededor del explorador. Sus pulsaciones son fuertes. Luego regresa al bosque.\nEXPLORADOR: Hasta pronto, pequeño."},
        {"title": "Regreso a las estrellas", "text": "LUMA: Propulsión auxiliar restablecida. La reparación no cumple los estándares recomendados.\nEXPLORADOR: Podemos tolerarlo.\nLa nave abandona la atmósfera de KORA."},
        {"title": "La última señal", "text": "Corta. Larga. Corta.\nLUMA: El origen está fuera de este sistema.\nEXPLORADOR: ¿Hay otro lugar como KORA?\nUna pregunta abierta, mientras el planeta vuelve a sostener vida."},
        {"title": "KORA / CRÉDITOS PROVISIONALES", "text": "La memoria de las estrellas · Boceto jugable\nProyecto y narrativa: Harold / documentos de KORA\nSprites del paquete suministrado: Ozzbit Games\nImplementación del boceto: asistencia de Codex\nFIN · Gracias por explorar."},
    ]}
    write("data/narrative.json", json.dumps(entries, ensure_ascii=False, indent=2) + "\n")


def reusable_scenes():
    # Root and collision data stay in .tscn so instances expose their properties.
    specs = {
        "InteractiveTerminal": ("Node2D", "interactive", "label"),
        "CrystalSwitch": ("Node2D", "interactive", "label"),
        "Checkpoint": ("Area2D", "checkpoint", "checkpoint"),
        "Hazard": ("Area2D", "hazard", "area"),
        "MovingPlatform": ("AnimatableBody2D", "moving_platform", "body"),
        "EnergyDoor": ("StaticBody2D", "door", "body"),
        "LevelExit": ("Node2D", "exit", "exit"),
        "BaseEnemy": ("CharacterBody2D", "enemy", "enemy"),
        "Boss": ("Node2D", "boss", ""),
        "StoryTrigger": ("Area2D", "story_trigger", "trigger"),
        "Decoration": ("Node2D", "../world/decoration", ""),
    }
    for name, (node_type, script, kind) in specs.items():
        script_path = "scripts/world/decoration.gd" if name == "Decoration" else f"scripts/entities/{script}.gd"
        collision = kind in ("checkpoint", "area", "body", "enemy", "trigger")
        text = f'[gd_scene load_steps={3 if collision else 2} format=3]\n\n[ext_resource type="Script" path="res://{script_path}" id="1"]\n'
        if collision:
            size = (42, 70) if kind == "checkpoint" else ((60, 180) if kind == "trigger" else (34, 32))
            text += f'\n[sub_resource type="RectangleShape2D" id="Shape"]\nsize = {gd(size)}\n'
        text += f'\n[node name="{name}" type="{node_type}"]\nscript = ExtResource("1")\n'
        if node_type == "Area2D":
            text += 'collision_layer = 0\ncollision_mask = 2\n'
        elif node_type in ("StaticBody2D", "AnimatableBody2D"):
            text += 'collision_layer = 1\ncollision_mask = 2\n'
        elif node_type == "CharacterBody2D":
            text += 'collision_layer = 8\ncollision_mask = 1\n'
        if collision:
            text += '\n[node name="CollisionShape2D" type="CollisionShape2D" parent="."]\nshape = SubResource("Shape")\n'
            if kind == "enemy":
                text += 'position = Vector2(0, -16)\n'
            elif kind in ("checkpoint", "trigger"):
                text += 'position = Vector2(0, -25)\n'
        if kind in ("label", "exit", "checkpoint"):
            label = "SALIDA / F" if kind == "exit" else ("CHECKPOINT" if kind == "checkpoint" else "TERMINAL / F")
            text += f'\n[node name="Label" type="Label" parent="."]\noffset_left = -100.0\noffset_top = -83.0\noffset_right = 100.0\noffset_bottom = -57.0\nhorizontal_alignment = 1\ntheme_override_font_sizes/font_size = 10\ntext = {gd(label)}\n'
        write(f"scenes/entities/{name}.tscn", text)


class Level:
    def __init__(self, index, title, objective, width, height=720, tint="4b88a0", entry="", hint=""):
        self.index, self.title, self.objective = index, title, objective
        self.width, self.height, self.tint = width, height, tint
        self.entry, self.hint = entry, hint
        self.floors, self.entities, self.labels, self.decorations, self.tasks = [], [], [], [], []
        self.spawn = (100, 320)
        self.exit = (width - 140, 320)
        self.path_length = width
        self.zones = []

    def floor(self, x, y, width, height=48):
        self.floors.append((x, y, width, height))
        return self

    def terrain(self, segments):
        for segment in segments:
            self.floor(*segment)
        return self

    def add(self, kind, x, y, **props):
        self.entities.append((kind, x, y, props))
        return self

    def task(self, x, y, key, label, story="", requires=(), locked="Activa primero el mecanismo anterior."):
        self.tasks.append(dict(key=key, label=label))
        self.add("InteractiveTerminal", x, y, title=label, state_key=key, story_id=story, required_keys=list(requires), locked_hint=locked)
        return self

    def record(self, x, y, id, label="Memoria opcional"):
        return self.add("InteractiveTerminal", x, y, title=label, record_id=id)

    def cp(self, x, y):
        return self.add("Checkpoint", x, y)

    def hazard(self, x, y, width=42, cycle=True, offset=0.0, disabled=""):
        return self.add("Hazard", x, y, width=float(width), cycle=cycle, phase_offset=offset, disabled_by=disabled)

    def enemy(self, x, y, hp=3, patrol=60):
        return self.add("BaseEnemy", x, y, max_health=hp * 25, patrol_distance=float(patrol))

    def platform(self, x, y, travel=(144, 0), width=96, duration=4.0, unstable=False, arena=False):
        return self.add("MovingPlatform", x, y, travel=travel, width=float(width), duration=duration, unstable=unstable, _arena=arena)

    def label(self, x, y, text):
        self.labels.append((x, y, text))
        return self

    def zone(self, x, y, title, instruction):
        self.zones.append(title)
        return self.label(x, y - 160, title + "\n" + instruction)

    def deco(self, x, y, kind="crystal", size=(64, 100)):
        self.decorations.append((x, y, kind, size))
        return self

    def gate(self, x, y, keys):
        return self.add("EnergyDoor", x, y, required_keys=keys)

    def boss(self, x, y, left, right, saren=False):
        self.tasks.append(dict(key="boss", label="Detén a Saren" if saren else "Supera a ORÚ"))
        self.add("Boss", x, y, display_name="SAREN" if saren else "ORÚ", max_health=600 if saren else 300,
                 arena_left=float(left), arena_right=float(right), saren=saren,
                 victory_story="SAREN_DEFEAT" if saren else "STORY_08", intro_story="STORY_16" if saren else "ORU_INTRO")
        self.add("EnergyDoor", left, y, arena_lock=True, height=230.0)
        self.gate(right, y, ["boss"])
        return self

    def save(self):
        chapter, section = self.index // 3 + 1, self.index % 3 + 1
        scene_path = f"levels/Level_{chapter}_{section}.tscn"
        all_kinds = sorted(set([e[0] for e in self.entities] + ["Decoration", "LevelExit"]))
        ext = ['[ext_resource type="Script" path="res://scripts/world/section.gd" id="Level"]', '[ext_resource type="PackedScene" path="res://scenes/player/player.tscn" id="Player"]']
        ext += [f'[ext_resource type="PackedScene" path="res://scenes/entities/{kind}.tscn" id="{kind}"]' for kind in all_kinds]
        shapes = [f'[sub_resource type="RectangleShape2D" id="Shape{i}"]\nsize = Vector2({w}, {h})' for i, (x, y, w, h) in enumerate(self.floors)]
        text = f'[gd_scene load_steps={1+len(ext)+len(shapes)} format=3]\n\n' + '\n'.join(ext) + '\n\n' + '\n\n'.join(shapes)
        color = tuple(int(self.tint[i:i+2], 16) / 255 for i in (0, 2, 4))
        color_text = "Color(%s, %s, %s, 1)" % color
        text += f'\n\n[node name="Level_{chapter}_{section}" type="Node2D"]\nscript = ExtResource("Level")\nsection_index = {self.index}\nbounds = Rect2(0, 0, {self.width}, {self.height})\npalette = {color_text}\nentry_story = {gd(self.entry)}\nentry_hint = {gd(self.hint)}\n'
        for layer in ["BackgroundArt", "Geometry", "WorldArt", "Entities", "Labels", "ForegroundArt", "Audio"]:
            text += f'\n[node name="{layer}" type="Node2D" parent="."]\n'
            if layer == "ForegroundArt":
                text += 'z_index = 5\n'
        for i, (x, y, w, h) in enumerate(self.floors):
            p = f"Geometry/Block{i}"
            text += f'\n[node name="Block{i}" type="StaticBody2D" parent="Geometry"]\nposition = Vector2({x}, {y})\ncollision_layer = 1\ncollision_mask = 2\n'
            if i in getattr(self, 'route_surfaces', set()):
                text += 'metadata/route_surface = true\n'
            text += f'\n[node name="CollisionShape2D" type="CollisionShape2D" parent="{p}"]\nposition = Vector2({w/2}, {h/2})\nshape = SubResource("Shape{i}")\n'
            text += f'\n[node name="Blockout" type="Polygon2D" parent="{p}"]\npolygon = PackedVector2Array(0, 0, {w}, 0, {w}, {h}, 0, {h})\ncolor = Color(0.13, 0.22, 0.29, 1)\n'
            text += f'\n[node name="Surface" type="Line2D" parent="{p}"]\npoints = PackedVector2Array(0, 0, {w}, 0)\nwidth = 2.0\ndefault_color = {color_text}\n'
        for i, (kind, x, y, props) in enumerate(self.entities):
            group = ' groups=["arena_platforms"]' if props.get("_arena") else ''
            text += f'\n[node name="{kind}{i}" parent="Entities"{group} instance=ExtResource("{kind}")]\nposition = Vector2({x}, {y})\n'
            for key, value in props.items():
                if not key.startswith("_"):
                    text += f'{key} = {gd(value)}\n'
        for i, (x, y, kind, size) in enumerate(self.decorations):
            text += f'\n[node name="Prop{i}" parent="WorldArt" instance=ExtResource("Decoration")]\nposition = Vector2({x}, {y})\nkind = {gd(kind)}\nsize = {gd(size)}\ntint = {color_text}\n'
        for i, (x, y, label) in enumerate(self.labels):
            text += f'\n[node name="Sign{i}" type="Label" parent="Labels"]\noffset_left = {float(x)}\noffset_top = {float(y)}\noffset_right = {float(x+350)}\noffset_bottom = {float(y+62)}\ntext = {gd(label)}\ntheme_override_font_sizes/font_size = 12\n'
        text += f'\n[node name="Exit" parent="Entities" instance=ExtResource("LevelExit")]\nposition = {gd(self.exit)}\nrequired_keys = {gd([task["key"] for task in self.tasks])}\n'
        text += f'\n[node name="Player" parent="." instance=ExtResource("Player")]\nposition = {gd(self.spawn)}\n'
        text += '\n[node name="Camera2D" type="Camera2D" parent="Player"]\nposition = Vector2(35, -70)\nposition_smoothing_enabled = false\n'
        write(scene_path, text)
        return dict(id=f"{chapter}.{section}", title=self.title, objective=self.objective, scene="res://"+scene_path,
                    width=self.width, height=self.height, route_length=self.path_length, zones=self.zones, tasks=self.tasks,
                    checkpoints=sum(e[0] == "Checkpoint" for e in self.entities))


def levels():
    result = []
    # 1.1 — crater, wreckage, recovery, overlook. Gentle traversal introduces controls.
    l = Level(0, "La nave destruida", "Inspecciona los restos de la nave", 4800, hint="A/D correr · Espacio saltar · F examinar · F1 selector de secciones")
    l.terrain([(0,320,740),(740,280,440),(1180,320,420),(1664,320,660),(2324,280,300),(2624,240,360),(2984,280,520),(3568,320,632),(4200,320,600)])
    l.task(500,320,"telemetry","Recupera la telemetría","STORY_02").task(1980,320,"cell","Recupera la célula","CELL",["telemetry"]).task(2810,240,"lookout","Examina el mirador","LOOKOUT",["cell"])
    l.cp(100,320).cp(1780,320).cp(3700,320)
    l.record(1030,280,"REG_SIGNAL","Fragmento cristalino")
    l.deco(280,320,"ship",(230,90)).deco(920,280).deco(3100,280,"ruins",(150,120))
    l.hazard(3900,320,42,False)
    for args in [(90,320,"01 / CRÁTER","Busca la terminal junto a la nave"),(810,280,"02 / RESTOS","Salta los desniveles · los cristales violetas son opcionales"),(1700,320,"03 / RESERVA","Recupera una célula para el equipo portátil"),(2670,240,"04 / MIRADOR","El camino continúa hacia las estructuras"),(3710,320,"05 / SALIDA DEL CRÁTER","Salta los fragmentos rojos")]: l.zone(*args)
    result.append(l)
    # 1.2 — life, SIL, optional upper path, first territorial enemy, underground signal.
    l = Level(1,"El primer contacto","Explora los alrededores del accidente",5200)
    l.terrain([(0,320,900),(900,360,560),(1520,360,600),(2120,320,640),(2840,320,760),(3600,280,320),(3920,320,560),(4560,320,640)])
    l.task(620,320,"sil","Acércate a SIL","STORY_03").task(4870,320,"scan","Analiza la señal subterránea","STORY_04",["sil"])
    l.cp(100,320).cp(1710,360).cp(3630,280)
    l.floor(980,320,80,12).floor(1090,280,100,12).floor(1220,240,120,12).record(1280,240,"REG_VOICE")
    l.enemy(2420,320,3,90).enemy(4150,320,3,80).hazard(3290,320,48,False)
    l.deco(660,320,"sil").deco(280,320,"tree").deco(1840,360,"tree").deco(2980,320,"sil").deco(4450,320,"crystal")
    for args in [(80,320,"01 / VIDA DESCONOCIDA","Sigue los pulsos de la criatura"),(980,360,"02 / SENDERO ALTO","Desvío opcional: una voz en el cristal"),(2180,320,"03 / TERRITORIO","J encadena golpes · arco amarillo: aléjate"),(3650,280,"04 / ECO PROFUNDO","Cruza los fragmentos y examina el resonador")]: l.zone(*args)
    result.append(l)
    # 1.3 — descending route, ferries and unstable stepping stones over a fracture.
    l = Level(2,"La grieta luminosa","Encuentra una fuente de energía",5000,920,tint="689fc7")
    l.terrain([(0,320,760),(820,360,580),(1640,400,600),(2240,440,500),(2880,480,620),(3560,520,580),(4140,560,860)])
    l.platform(1420,360,(124,40),96,4.5).platform(2760,440,(0,0),100,4.0,True)
    l.task(1860,400,"pillar","Sintoniza el pilar","STORY_05").task(3860,520,"sample","Extrae una muestra limitada","SAMPLE",["pillar"])
    l.cp(100,320).cp(1180,360).cp(2420,440).cp(3620,520)
    l.hazard(3210,480,48,True).deco(2330,690,"crystal",(150,250)).deco(4510,560,"ruins",(180,170))
    for args in [(90,320,"01 / BORDE DE LA GRIETA","Desciende por las repisas"),(1050,360,"02 / PLATAFORMA MÓVIL","Espera el transporte azul en el borde"),(2280,440,"03 / PASO INESTABLE","La plataforma violeta cede en 0,85 s y reaparece"),(3660,520,"04 / FUENTE ENERGÉTICA","Toma solo lo necesario"),(4300,560,"05 / EL SANTUARIO LEJANO","Cruza hacia el bosque resonante")]: l.zone(*args)
    l.exit=(4860,560)
    result.append(l)
    # 2.1 — restore two gardens; optional Eshar record on a raised branch.
    l=Level(3,"Jardines de cristal","Investiga la Resonancia",5600,tint="67b89e")
    l.terrain([(0,320,880),(960,320,680),(1640,280,360),(2000,320,600),(2840,320,660),(3500,280,400),(3980,320,700),(4760,320,840)])
    l.platform(2620,320,(124,0),96,4.0)
    l.task(640,320,"sil","Sigue a SIL","SIL_RETURN").task(1420,320,"garden_a","Activa el jardín oeste",requires=["sil"]).task(3240,320,"garden_b","Activa el jardín este",requires=["garden_a"]).task(5040,320,"sanctuary","Abre el santuario","STORY_06",["garden_a","garden_b"])
    l.gate(5240,320,["sanctuary"]).cp(100,320).cp(2220,320).cp(4220,320)
    l.floor(1740,240,80,12).floor(1860,200,100,12).record(1910,200,"REG_01")
    l.hazard(1130,320,56,True,0.0,"garden_a").hazard(3010,320,56,True,1.0,"garden_b").enemy(4480,320,3,100)
    for x,y in [(300,320),(1110,320),(2320,320),(3610,280),(4850,320)]: l.deco(x,y,"tree",(100,130))
    l.deco(690,320,"sil")
    for args in [(80,320,"01 / SIL REGRESA","La luz de los jardines se está apagando"),(1000,320,"02 / JARDÍN OESTE","Reposo azul · aviso amarillo · descarga roja"),(2250,320,"03 / CAUCE RESONANTE","Cruza con la plataforma móvil"),(2930,320,"04 / JARDÍN ESTE","Restituye la energía local"),(4800,320,"05 / UMBRAL ESHAR","Los dos jardines alimentan el santuario")]: l.zone(*args)
    result.append(l)
    # 2.2 — spacious puzzle chamber with a legible permanent order and archive gate.
    l=Level(4,"El santuario silencioso","Activa los mecanismos del santuario",5000,tint="9b91c9")
    l.terrain([(0,320,720),(780,320,820),(1600,280,340),(1940,320,1960),(3980,320,1020)])
    l.task(1080,320,"clue","Lee la inscripción","PUZZLE_CLUE")
    l.tasks.append(dict(key="sequence",label="Sintoniza I → III → II"))
    for x,order,title in [(2220,1,"I / Primer resonador"),(2520,2,"II / Segundo resonador"),(2820,3,"III / Tercer resonador")]:
        l.add("CrystalSwitch",x,320,title=title,order=order)
    l.gate(3130,320,["sequence"]).task(3470,320,"ayen","Consulta el archivo de Ayen","STORY_07",["sequence"])
    l.cp(100,320).cp(2050,320).cp(4180,320)
    l.floor(1720,240,80,12).floor(1840,200,120,12).record(1890,200,"REG_02")
    for x in [420,1480,3060,3700,4510]: l.deco(x,320,"ruins",(140,145))
    for args in [(80,320,"01 / RUINAS GEOMÉTRICAS","Una memoria construida sobre la piedra"),(900,320,"02 / LA INSCRIPCIÓN","Examina la pista antes del ritual"),(2120,320,"03 / CÁMARA DE RESONADORES","ORDEN: I → III → II · sin daño al reintentar"),(3310,320,"04 / ARCHIVO DE AYEN","El nombre del planeta espera tras la puerta"),(4200,320,"05 / DEFENSAS ANTIGUAS","La autorización requiere superar al guardián")]: l.zone(*args)
    result.append(l)
    # 2.3 — approach, safe checkpoint outside arena, clear combat tutorial, authorization.
    l=Level(5,"El guardián del bosque","Supera las defensas del santuario",4400,tint="7aa9b8")
    l.terrain([(0,320,800),(880,320,680),(1560,280,360),(1920,320,2480)])
    l.cp(100,320).cp(2160,320).hazard(1190,320,52,True).enemy(1760,280,3,50)
    l.boss(3020,320,2440,3580).task(3910,320,"permit","Recoge la autorización",requires=["boss"])
    l.floor(2630,278,92,12).floor(3330,278,92,12)
    for args in [(80,320,"01 / APROXIMACIÓN","Los protocolos del santuario siguen activos"),(990,320,"02 / DEFENSAS","Espera el reposo y cruza"),(2050,320,"03 / PREPARACIÓN","Checkpoint fuera de la arena · J para atacar"),(2540,320,"04 / ORÚ","Arco: retrocede · onda: salta · verde: ataca"),(3750,320,"05 / AUTORIZACIÓN","El camino desciende hacia la red")]: l.zone(*args)
    result.append(l)
    # 3.1 — timing and ethical optional rescue, disable hazardous route on completion.
    l=Level(6,"Cavernas de resonancia","Atraviesa las cavernas",5600,840,tint="688aca",entry="STORY_09")
    l.terrain([(0,320,680),(744,360,520),(1330,320,560),(1954,360,640),(2834,400,640),(3538,360,600),(4202,400,620),(4886,440,714)])
    l.platform(2614,360,(124,40),96,4.2)
    l.cp(100,320).cp(2040,360).cp(4280,400)
    for x,y,offset in [(950,360,0),(1510,320,1),(3070,400,0.5),(3770,360,1.6),(5120,440,0.8)]: l.hazard(x,y,56,True,offset,"regulator")
    l.add("InteractiveTerminal",2320,360,title="Libera a la criatura (opcional)",state_key="rescued",story_id="RESCUE").deco(2380,360,"sil")
    l.floor(4400,360,90,12).floor(4520,320,110,12).record(4570,320,"REG_INSCRIPTION")
    l.task(5380,440,"regulator","Activa el regulador","REGULATOR")
    for args in [(80,320,"01 / PULSACIONES","Dos segundos de reposo antes del aviso"),(1450,320,"02 / SALTOS EN CICLO","Los saltos mantienen la física del explorador"),(2140,360,"03 / UNA CRIATURA ATRAPADA","Puedes abrir su compuerta sin alterar la ruta"),(3000,400,"04 / SOBRECARGA","Combina espera, salto y descanso"),(4930,440,"05 / REGULADOR","Reduce la descarga antes de salir")]: l.zone(*args)
    l.exit=(5480,440)
    result.append(l)
    # 3.2 — archives on main path guarantee reveals without optional records.
    l=Level(7,"El complejo abandonado","Investiga el Proyecto Vigilia",6200,tint="9292bd")
    l.terrain([(0,320,980),(1040,320,1060),(2100,280,360),(2460,320,1120),(3640,320,960),(4660,360,700),(5420,320,780)])
    l.task(650,320,"vigilia","Consulta Proyecto Vigilia","STORY_10").task(1710,320,"warning","Escucha la advertencia","STORY_11",["vigilia"]).task(3130,320,"saren","Abre el archivo de Saren","STORY_12",["warning"]).task(4250,320,"transmissions","Revisa las transmisiones","TRANSMISSIONS",["saren"]).task(5820,320,"redirect","Redirige la energía","REDIRECT",["transmissions"])
    l.cp(100,320).cp(2550,320).cp(4780,360).gate(6020,320,["redirect"])
    l.floor(1180,280,90,12).floor(1300,240,110,12).record(1350,240,"REG_03")
    l.floor(3820,280,90,12).floor(3940,240,110,12).record(3990,240,"REG_04")
    l.hazard(5060,360,56,True).enemy(5610,320,4,70)
    for x in [420,800,1560,2790,3370,4100,4440]: l.deco(x,320,"memory")
    for args in [(80,320,"01 / PROYECTO VIGILIA","Recorre los archivos principales"),(1450,320,"02 / LAS CÁMARAS","Ayen advirtió el costo energético"),(2760,320,"03 / CONTENCIÓN","Una conciencia custodia el núcleo"),(3760,320,"04 / REGISTROS IMPOSIBLES","No existe un emisor válido"),(5470,320,"05 / ENERGÍA DE EMERGENCIA","Abre la ruta de mantenimiento")]: l.zone(*args)
    result.append(l)
    # 3.3 — true vertical serpentine: visible 120px drops, two lifts and safe stairs.
    l=Level(8,"El descenso","Alcanza el núcleo profundo",1500,2520,tint="667cab",entry="DESCENT")
    l.path_length=8300
    l.spawn=(140,240)
    l.floor(0,240,520).floor(620,360,740).floor(140,480,540).floor(800,600,560).floor(140,720,540).floor(800,840,560).floor(140,960,540).floor(800,1080,560).floor(140,1200,540).floor(800,1320,560).floor(140,1440,540).floor(800,1560,560).floor(140,1680,540).floor(800,1800,560).floor(140,1920,540).floor(800,2040,560).floor(140,2160,1220)
    # Alternating shelves overlap at the transfer edge through intermediate islands.
    for y in range(480,2161,240):
        l.floor(680,y-60,120,12)
    for y in range(600,2041,240):
        l.floor(680,y-60,120,12)
    # Side elevators are a deliberate optional shortcut; all landings have a static route.
    l.platform(30,480,(0,480),90,8.0).platform(1370,1200,(0,600),90,10.0)
    l.cp(140,240).cp(1040,600).cp(340,1200).cp(1030,1800).cp(340,2160)
    l.task(1120,840,"conduit","Examina el conducto","CONDUIT").task(350,1680,"echo","Escucha el eco de tu voz","STORY_13",["conduit"])
    l.record(390,1440,"REG_05")
    l.platform(1020,1038,(0,0),100,4.0,True).hazard(360,960,48,True).hazard(1080,1560,48,True,1.0).hazard(600,2160,52,True)
    for x,y in [(200,240),(870,600),(190,1200),(880,1800),(240,2160)]: l.zone(x,y,"DESCENSO / %d m"%(y//6),"Mira la repisa inferior antes de dejarte caer")
    l.label(670,285,"↓").label(710,525,"↓").label(710,1005,"↓").label(710,1485,"↓")
    l.deco(740,2000,"core",(180,380))
    l.exit=(1220,2160)
    result.append(l)
    # 4.1 — corrupted terraces, harder wildlife, three independently persistent stabilizers.
    l=Level(9,"La zona corrompida","Restablece los estabilizadores",6200,800,tint="b77d99")
    l.terrain([(0,320,760),(824,360,600),(1488,320,620),(2248,360,700),(3012,320,640),(3892,360,680),(4636,320,660),(5360,360,840)])
    l.platform(2128,320,(0,0),100,4.0,True).platform(3676,320,(120,40),96,3.8)
    l.task(1130,360,"conduit","Abre el conducto de emergencia","CONDUIT").task(1840,320,"stabilizer_a","Activa estabilizador A",requires=["conduit"]).task(3370,320,"stabilizer_b","Activa estabilizador B",requires=["stabilizer_a"]).task(5780,360,"stabilizer_c","Activa estabilizador C",requires=["stabilizer_b"])
    l.cp(100,320).cp(2330,360).cp(4760,320)
    for x,y,offset in [(960,360,0),(1600,320,0.6),(3220,320,1),(4120,360,0.2),(5510,360,1.8)]: l.hazard(x,y,56,True,offset,"conduit" if x<1500 else "")
    l.enemy(2630,360,4,80).enemy(4380,360,4,70).enemy(5090,320,4,60)
    for x,y in [(530,320),(2810,360),(3530,320),(5960,360)]: l.deco(x,y,"crystal",(85,130))
    for args in [(80,320,"01 / FRACTURA","La extracción sigue alterando a los organismos"),(1530,320,"02 / ESTABILIZADOR A","Asegura el primer conducto"),(3070,320,"03 / ESTABILIZADOR B","El paso violeta es inestable"),(4730,320,"04 / ÚLTIMO AVANCE","Descansa en el checkpoint antes de continuar"),(5410,360,"05 / ESTABILIZADOR C","La cámara requiere los tres estabilizadores")]: l.zone(*args)
    l.gate(5980,360,["stabilizer_a","stabilizer_b","stabilizer_c"])
    l.exit=(6060,360)
    result.append(l)
    # 4.2 — quiet monumental gallery: reflective traversal, final recording, phase transmitter.
    l=Level(10,"La cámara del núcleo","Descubre cómo liberar la Resonancia",5000,tint="bca877",entry="STORY_14")
    l.terrain([(0,320,1000),(1060,320,700),(1760,280,360),(2120,320,1140),(3320,320,700),(4020,280,400),(4420,320,580)])
    l.task(1390,320,"ayen_last","Escucha la última grabación","AYEN_LAST").task(2730,320,"console","Examina la consola del núcleo","CORE_CONSOLE",["ayen_last"]).task(3760,320,"phase","Investiga el transmisor de fase","STORY_15",["console"])
    l.cp(100,320).cp(2250,320).cp(4680,320)
    l.floor(4120,240,85,12).floor(4240,200,120,12).record(4300,200,"REG_06")
    l.deco(2950,340,"core",(280,260))
    for x in [390,720,1590,2420,3170,3570,4510]: l.deco(x,320,"memory")
    for args in [(80,320,"01 / GALERÍA DE ECOS","Siglos dentro de un mismo instante"),(1140,320,"02 / AYEN","Recuerda quién fue Saren"),(2300,320,"03 / LA DECISIÓN","Liberar la memoria devuelve energía a la vida"),(3400,320,"04 / ECO DE FASE","El origen de la señal aún está por ocurrir"),(4490,320,"05 / ÚLTIMO DESCANSO","El guardián espera al otro lado")]: l.zone(*args)
    result.append(l)
    # 4.3 — approach, final two-phase arena, then three explicit interactions resolve the story.
    l=Level(11,"El corazón fracturado","Detén a Saren y restaura el núcleo",5400,tint="bb8ac5")
    l.terrain([(0,320,800),(864,320,650),(1514,280,360),(1874,320,3526)])
    l.cp(100,320).cp(2080,320).hazard(1130,320,52,True)
    l.boss(3000,320,2350,3680,True)
    l.platform(2550,278,(0,0),100,4.0,False,True).platform(3340,278,(0,0),100,4.0,False,True)
    l.task(3920,320,"release","Libera las memorias","STORY_17",["boss"])
    l.task(4450,320,"signal","Envía la señal al pasado","STORY_18",["release"],"Primero libera el almacenamiento permanente.")
    l.task(4920,320,"restore","Estabiliza el núcleo","STORY_19",["signal"],"Completa la transmisión antes de estabilizar el núcleo.")
    l.deco(3000,320,"core",(380,300))
    for args in [(80,320,"01 / LA ÚLTIMA PUERTA","Cruza las defensas restantes"),(1970,320,"02 / PREPARACIÓN","Escudo violeta · recuperación verde: golpea"),(2460,320,"03 / SAREN","Lee la barra del jefe: cada ataque tiene una respuesta"),(3810,320,"04 / LIBERACIÓN","Desactiva el almacenamiento permanente"),(4310,320,"05 / LA SEÑAL","Corta · larga · corta"),(4840,320,"06 / EL SILENCIO","Estabiliza la Resonancia y regresa a la superficie")]: l.zone(*args)
    result.append(l)
    from hard_campaign import apply
    apply(result, write)
    for level in result:
        # Left safety wall: cannot leave the intended route by walking backward.
        level.floor(-24,0,24,level.height+100)
        level.floor(level.width,0,24,level.height+100)
    write("data/sections.json",json.dumps([level.save() for level in result],ensure_ascii=False,indent=2)+"\n")


def ui_scenes():
    menu = '''[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://scripts/ui/main_menu.gd" id="1"]
[node name="MainMenu" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1")
[node name="Background" type="ColorRect" parent="."]
offset_right = 640.0
offset_bottom = 360.0
color = Color(0.035, 0.06, 0.105, 1)
[node name="Title" type="Label" parent="."]
offset_left = 38.0
offset_top = 27.0
text = "KORA"
theme_override_font_sizes/font_size = 40
theme_override_colors/font_color = Color(0.5, 0.92, 0.86, 1)
[node name="Subtitle" type="Label" parent="."]
offset_left = 40.0
offset_top = 82.0
text = "LA MEMORIA DE LAS ESTRELLAS"
theme_override_font_sizes/font_size = 13
[node name="Version" type="Label" parent="."]
offset_left = 40.0
offset_top = 113.0
text = "Boceto jugable · Prólogo + 12 secciones + Epílogo"
theme_override_font_sizes/font_size = 11
[node name="Legend" type="Label" parent="."]
offset_left = 341.0
offset_top = 148.0
offset_right = 615.0
text = "EXPLORA LA RESONANCIA\nTurquesa / mecanismos\nVerde / checkpoint y salida\nVioleta / memorias opcionales\nAmarillo / aviso de peligro\nRojo / descarga o ataque\nF1: selector de secciones"
theme_override_font_sizes/font_size = 11
theme_override_constants/line_spacing = -2
[node name="Footer" type="Label" parent="."]
offset_left = 40.0
offset_top = 337.0
text = "Progreso durante esta sesión · Sprites: Ozzbit Games · Arte y audio provisionales"
theme_override_font_sizes/font_size = 10
'''
    for i,(name,title) in enumerate([("NewGame","Comenzar aventura"),("Continue","Continuar sesión"),("Sections","Selector de secciones"),("Laboratory","Laboratorio de sprites"),("Exit","Salir")]):
        menu += f'\n[node name="{name}" type="Button" parent="."]\noffset_left = 40.0\noffset_top = {140.0+i*36}\noffset_right = 302.0\noffset_bottom = {170.0+i*36}\ntext = {gd(title)}\ntheme_override_font_sizes/font_size = 14\n'
    write("ui/MainMenu.tscn",menu)
    for name,epilogue in [("Prologue",False),("Epilogue",True)]:
        text = f'''[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://scripts/ui/cinematic.gd" id="1"]
[node name="{name}" type="Control"]
script = ExtResource("1")
epilogue = {gd(epilogue)}
[node name="Heading" type="Label" parent="."]
offset_left = 36.0
offset_top = 20.0
offset_right = 615.0
theme_override_font_sizes/font_size = 22
theme_override_colors/font_color = Color(0.55, 0.91, 0.85, 1)
[node name="Text" type="Label" parent="."]
offset_left = 38.0
offset_top = 173.0
offset_right = 604.0
offset_bottom = 296.0
autowrap_mode = 3
theme_override_font_sizes/font_size = 12
theme_override_constants/line_spacing = -2
[node name="Counter" type="Label" parent="."]
offset_left = 565.0
offset_top = 140.0
theme_override_font_sizes/font_size = 12
[node name="Next" type="Button" parent="."]
offset_left = 330.0
offset_top = 309.0
offset_right = 604.0
offset_bottom = 343.0
focus_mode = 0
theme_override_font_sizes/font_size = 13
[node name="Skip" type="Button" parent="."]
offset_left = 38.0
offset_top = 309.0
offset_right = 280.0
offset_bottom = 343.0
focus_mode = 0
theme_override_font_sizes/font_size = 13
'''
        write(f"levels/{name}.tscn",text)


if __name__ == "__main__":
    narrative()
    reusable_scenes()
    levels()
    ui_scenes()
    print("12 secciones + prólogo + epílogo + entidades + narrativa creados.")
