"""Recrea las envolventes y filtros de Web Audio del laboratorio en WAV PCM.

Se conservan frecuencias, duraciones, ganancias, curvas exponenciales y Q=1.
El oscilador PCM puede diferir del oscilador bandlimited del navegador.
"""
import math
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RATE = 48000


def oscillator(kind, start, end, seconds, gain, filtering=None):
    result = []
    phase = 0.0
    x1 = x2 = y1 = y2 = 0.0
    for i in range(round(seconds * RATE)):
        t = i / RATE / seconds
        frequency = start * (end / start) ** t
        value = math.sin(phase * 2 * math.pi) if kind == "sine" else (2 * phase - 1 if kind == "sawtooth" else (1 if phase < 0.5 else -1))
        phase = (phase + frequency / RATE) % 1.0
        if filtering:
            mode, f0, f1 = filtering
            omega = 2 * math.pi * (f0 + (f1 - f0) * t) / RATE
            cs, sn = math.cos(omega), math.sin(omega)
            alpha = sn / 2  # Web Audio default Q = 1.
            if mode == "lowpass":
                b0, b1, b2 = (1-cs)/2, 1-cs, (1-cs)/2
            else:
                b0, b1, b2 = alpha, 0, -alpha
            a0, a1, a2 = 1+alpha, -2*cs, 1-alpha
            filtered = (b0*value + b1*x1 + b2*x2 - a1*y1 - a2*y2) / a0
            x2, x1, y2, y1 = x1, value, y1, filtered
            value = filtered
        result.append(value * gain * (0.01/gain) ** t)
    return result


def save(name, samples):
    path = ROOT / "assets/audio/player" / (name + ".wav")
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(b"".join(struct.pack("<h", round(max(-1, min(1, sample)) * 32767)) for sample in samples))


if __name__ == "__main__":
    for pitch in [0.8, 0.85, 1.0, 1.1, 1.35]:
        save(f"slash_{round(pitch*100)}", oscillator("sawtooth",520*pitch,100,0.14,0.3,("lowpass",1600,300)))
    save("dash", oscillator("sawtooth",420,140,0.18,0.35,("bandpass",900,250)))
    save("jump", oscillator("sine",180,360,0.1,0.18))
    save("hit", oscillator("square",220,50,0.1,0.35))
    slam = oscillator("sawtooth",140,30,0.28,0.45)
    sub = oscillator("sine",90,25,0.35,0.55)
    save("slam", [sub[i]+(slam[i] if i<len(slam) else 0) for i in range(len(sub))])
    print("9 efectos de sonido creados con los parámetros del HTML.")
