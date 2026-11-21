# Control del laboratorio HTML en Godot

**Nota de versión:** este documento describe la importación original. Las hojas actuales de combate tienen nueve celdas, 22/22/20 FPS y otras ventanas de impacto; la comparación automática con el HTML ahora cubre únicamente los 8 escenarios de movimiento (960 fotogramas). La campaña añade un dash aéreo por salto, cámara adelantada y daño más exigente. Consulta RETO_EXIGENTE.md y README.md para el estado actual. Los detalles históricos de combate siguientes no describen la versión actual.

Referencia: `C:/Users/Harold/Desktop/KoraSrites-Laboratorio/lab_sprite_testing.html`. Se conserva una copia en `tests/fixtures/lab_reference.html`. Los archivos del escritorio permanecen intactos. Copia previa del proyecto: `.local/control-html-original`.

La petición actual de reproducir el laboratorio recupera `walk` y el modificador Shift/LB que se habían retirado. Con teclado ya se corre sin Shift; caminar aparece con stick parcial y durante las transiciones originales.

## Probar

Abre **JUGAR_LABORATORIO.bat** o el botón Laboratorio del menú. F4 abre los ajustes de física, escala, FPS, estados forzados y avance de un fotograma. F1 abre la galería; Tab vuelve al menú. R restablece posición y velocidad, conservando los temporizadores como el HTML. B coloca el saco delante del personaje. P/Esc pausa.

| Acción | Teclado / ratón | Mando |
|---|---|---|
| Mover | A/D, flechas | Stick izquierdo / cruceta |
| Modificador de carrera | Shift | LB |
| Salto variable | Espacio, W, arriba | A |
| Combo | J, clic izquierdo | X |
| Fuerte | I, U, Y, clic derecho | Y |
| Dash | K, E, X | B, RB, RT |

En la campaña, **F** interactúa y avanza conversaciones, porque E pertenece al dash original. Enter también avanza los diálogos.

## Qué se trasladó

`lab_motion.gd` conserva el orden de actualización, aceleración terrestre 22 y aérea 12, frenado de ataque 6, salto 380, gravedad 950, tolerancia de borde 0,10 s y memoria de salto 0,12 s. Mantiene el salto corto al soltar, gravedad reducida al atacar en el aire, dash 520 durante 0,22 s con recarga 0,40 s y cancelación de ataques mediante dash.

Los combos mantienen sus impulsos, búferes, prioridad del fuerte, ventanas de impacto y daños 25/45/60/15. El envaine también golpea, tal como sucede en el código original. Las animaciones avanzan como máximo una celda por actualización; el dash reproduce correr a 18 FPS. Los golpes usan 10/10/11/10 FPS: estos son los valores efectivos del HTML, aunque su interfaz incluya un regulador de combo que no gobierna esos tiempos.

`player.gd` adapta las entradas, sprites y cámara. `player_effects.gd` reproduce polvo, estelas, arcos, impactos, números, sacudida y llamadas de vibración. El saco conserva 100 de salud, reinicio al agotarse, destello y balanceo. Las hojas originales suman 10 animaciones y 57 celdas de 128×128.

## Verificación y límites

- `build_lab_reference.cjs` ejecuta el objeto del jugador original mediante Node; sustituye únicamente los servicios del navegador que no intervienen en la física. Produce 20 escenarios y 2.210 fotogramas.
- `lab_parity_test.gd` compara posiciones, velocidades, estados, celdas, temporizadores, búferes y daños. Tolerancia numérica de 0,000001; estados y celdas exactos.
- `lab_integration_test.gd` reproduce esas trazas mediante el jugador real, su sprite y el saco. Posición con tolerancia de 0,01 por la representación Vector2 de Godot; estados, celdas y salud exactos.
- La campaña también se comprueba mediante pruebas de integración y 103 conexiones de plataformas. Las amenazas se desactivan solamente en la prueba de recorridos.

La pista de referencia utiliza el mismo apoyo puntual y las mismas plataformas atravesables desde abajo del HTML. **La campaña mantiene las colisiones nativas de Godot** para sus paredes, puertas y plataformas móviles; los contactos con esos elementos no son idénticos a la pista HTML. El controlador compartido conserva los parámetros y estados originales.

El HTML actualiza con el tiempo del navegador; Godot juega a 60 pasos físicos por segundo. Se compararon pasos de 60 Hz y tiempos variables en la lógica, pero no se promete equivalencia bajo cualquier frecuencia de pantalla o latencia de entrada. La cámara conserva interpolación 0,12 y sacudida; los límites y el encuadre de la sección vertical siguen adaptados a la campaña.

Los WAV recrean frecuencias, duraciones, envolventes y filtros de la síntesis original mediante `tools/build_player_audio.py`. Web Audio y este sintetizador no producen una onda idéntica bit a bit. Los efectos aleatorios tampoco comparten semilla con el navegador. Se verificó la carga de audio y las capturas renderizadas; queda pendiente comparar de oído y probar vibración con un mando físico.

Ejecuta **VERIFICAR_PROYECTO.bat** para las cinco suites. Node solo hace falta si regeneras las trazas; Python solo si regeneras sprites o sonidos. Las capturas se generan con `tests/capture_lab.gd` y `tests/capture_campaign.gd` ejecutados con renderizado.
