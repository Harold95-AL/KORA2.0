# Sprites y movimiento



- **Escena reutilizable:** `scenes/player/player.tscn`. Instánciala en futuras escenas de nivel.
- **Animaciones compartidas:** `resources/player/player_frames.tres`. La galería utiliza el mismo recurso. Durante el juego, `scripts/player/lab_motion.gd` controla manualmente los tiempos y las transiciones para reproducir el HTML: ajusta allí `FRAMES`, `FPS` y `fps_overrides` si cambias el número o la velocidad de las celdas.
- **Imágenes:** `assets/sprites/player/`. Se copiaron las hojas activas del laboratorio suministrado, sin mezclar las carpetas de copias antiguas.
- Cada hoja tiene una fila de celdas de **128 × 128 px**. El personaje ocupa solo parte de cada celda: no recortes el margen transparente sin corregir su anclaje.
- El punto de apoyo está en **(64, 80)** dentro de la celda. El nodo del jugador marca los pies; `AnimatedSprite2D.position = (0, -16)` compensa el centrado de la imagen. La colisión mide **26 × 38 px**, con centro en **(0, -19)**.
- Si sustituyes una hoja por otra del mismo tamaño, nombre y distribución, Godot actualiza la importación. Si cambias el número de celdas, ajusta SpriteFrames.
- Alternativa reproducible: edita `data/player_animations.json` y ejecuta `python tools/import_sprites.py` con Python 3. El generador valida las dimensiones PNG y **reemplaza** `player_frames.tres`; no lo ejecutes después de editar ese recurso a mano sin guardar tus cambios.

| Animación | Fotogramas | FPS | Bucle |
|---|---:|---:|---|
| idle | 10 | 8 | Sí |
| walk | 10 | 10 | Sí |
| run | 10 | 14 | Sí |
| dash | 9 | 18 | No |
| jump | 6 | 12 | No |
| fall | 4 | 12 | No |
| fall_loop | 3 | 10 | Sí |
| combo_1 | 9 | 22 | No |
| combo_2 | 9 | 22 | No |
| combo_3 | 9 | 20 | No |
| combo_1_end | 4 | 12 | No |

La hoja `male_hero-design.png` se conserva como referencia estática. No forma parte de las 11 animaciones / 83 fotogramas. `walk` aparece con stick parcial y durante la aceleración o frenado. Al terminar las nueve celdas del dash, la carrera continúa en `run`.

## Ajustar movimiento y escenario

Selecciona **Player** en el Inspector para ajustar los parámetros exportados del controlador. El teclado corre automáticamente; el stick parcial permite caminar y Shift/LB activa el modificador del HTML:

| Parámetro | Valor |
|---|---:|
| Correr con A/D o flechas | 210 px/s |
| Caminar con stick parcial | 110 px/s × eje |
| Dash | 520 px/s, 0,22 s; recarga 0,40 s |
| Impulso de salto | 380 px/s |
| Gravedad | 950 px/s² |
| Tolerancia al salir de una plataforma | 0,10 s |
| Memoria de pulsación de salto | 0,12 s |

El salto completo tiene una altura teórica de unos 76 px; la integración física da una altura ligeramente menor. `scenes/lab/reference_lab.tscn` reproduce las plataformas originales del HTML. Sus polígonos están en **Geometry** y sus superficies de colisión en `Player.reference_platforms`: edita ambos si rediseñas esa pista. La pista anterior de Godot permanece en `scenes/lab/sprite_lab.tscn` para pruebas de colisión nativa.

El controlador incluye combos aéreos, golpe fuerte, envaine, dash en aire y suelo, mando, ratón, partículas, estelas, sacudida y sonidos. La aventura añade salud y ventanas de invulnerabilidad tras recibir daño; el dash no concede inmunidad. Consulta `CONTROL_LABORATORIO.md` para la comparación y las diferencias de integración.

Configuración de imagen: base **1920 × 1080**, ventana Full HD ajustada al monitor, renderizado **canvas_items**, escalado proporcional fraccional y renderizador **Compatibility**. La interfaz se adapta hasta 640 × 360; las bandas mantienen 16:9 en otras proporciones. El filtro **Nearest** conserva los sprites y las fuentes MSDF mantienen legibles los textos con distintos tamaños y zoom. Los píxeles pueden ocupar tamaños fraccionales al redimensionar. F11 alterna pantalla completa. Las capas físicas mantienen sus nombres y tamaños en unidades de mundo.

`scripts/ui/display_layout.gd` convierte las medidas de autoría antiguas a controles Full HD, incluyendo fuentes, mínimos y separaciones; no amplía una imagen de 640 × 360. Se aplica al menú, cinemáticas, HUD, paneles y galerías. `autoload/display_settings.gd` controla el ajuste inicial y F11. La cámara usa un zoom base de 4,5 y mantiene el mismo campo visible al cambiar el tamaño de ventana.


La campaña limita el dash aéreo a uno por salto y lo recupera al aterrizar. El laboratorio conserva el dash aéreo repetible. Los combos actuales difieren del HTML original; consulta RETO_EXIGENTE.md.
