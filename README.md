# KORA · La memoria de las estrellas

Boceto jugable completo para **Godot 4.7.2 / GDScript**: menú → prólogo → 12 secciones → epílogo → menú. Escenarios geométricos, narrativa editable y sprites del explorador conservados para usar esta base como lienzo de producción.

La campaña ahora tiene dificultad alta por defecto: **37 cruces con dash, 49 enemigos, 40 peligros y dos jefes con ataques encadenados**. Consulta [RETO_EXIGENTE.md](docs/RETO_EXIGENTE.md) para parámetros y criterios de prueba.

## Jugar

1. Abre **ABRIR_GODOT.bat**, o importa `project.godot` en Godot.
2. Pulsa **F5** y elige **Comenzar aventura**.
3. Para probar una zona directamente, usa **Selector de secciones** en el menú o **F1** durante la aventura.

**JUGAR_AVENTURA.bat** ejecuta el menú sin abrir el editor. **JUGAR_LABORATORIO.bat** abre la réplica de la pista HTML, con saco y ajustes F4. No necesitas Python para jugar o editar en Godot.

Si mueves Godot, actualiza `.local/godot-path.txt` o define `GODOT_PATH`. El lanzador también busca `godot` / `godot4` en PATH. Puedes importar siempre `project.godot` directamente desde el editor.

Resolución base **1920 × 1080**, con renderizado nativo e interfaz adaptable hasta **640 × 360**. La ventana arranca en Full HD si cabe en el monitor; en pantallas pequeñas se ajusta al área disponible. Puedes redimensionarla y usar **F11** para alternar pantalla completa. Se mantiene la proporción 16:9 con bandas cuando hace falta, sin cambiar el encuadre ni las distancias de los saltos. Los sprites conservan su estilo pixel art y los textos usan fuentes escalables.

## Controles

| Tecla | Aventura |
|---|---|
| A / D o flechas | Correr; aceleración y frenado del HTML |
| Espacio / W / flecha arriba | Saltar; mantener para el salto completo |
| J / clic izquierdo | Atacar; otra pulsación durante el golpe encadena hasta tres |
| I / U / Y / clic derecho | Golpe fuerte independiente o remate del combo |
| K / E / X | Dash; en campaña, uno aéreo por salto, recargado al aterrizar |
| F | Usar el objeto cercano / avanzar una conversación |
| Enter | Avanzar una conversación o cinemática |
| Esc | Pausa; cerrar conversación; omitir prólogo |
| Tab | Registros encontrados, releíbles |
| R | Recargar desde el checkpoint |
| F1 | Selector de las 12 secciones, prólogo y epílogo |
| F2 | Mostrar colisión y anclaje de pies del explorador |
| F11 | Alternar pantalla completa / recuperar el tamaño de ventana anterior |

En el laboratorio: **F1** galería, **F4** ajustes, **B** recolocar saco, **P/Esc** pausa y **Tab** menú. Mando: stick/cruceta para mover, A salto, X combo, Y fuerte, B/RB/RT dash, LB modificador de carrera. El stick permite caminar; Shift/LB reproduce el modificador del HTML. Con teclado ya corres sin mantener Shift.

## Reglas del boceto

- Los mecanismos turquesa requieren **F**; **E** queda reservado al dash del HTML. El HUD muestra el siguiente objetivo; la salida se activa al completar los objetivos principales.
- Los cristales violetas son registros opcionales. Ninguno bloquea el avance.
- Las banderas son checkpoints: recuperan los 6 puntos de energía y fijan el punto de reaparición.
- Los peligros cíclicos pasan por reposo, aviso amarillo y descarga roja. Los fragmentos rojos fijos dañan al tocarlos.
- Las plataformas azules son más estrechas y rápidas. Las violetas ceden entre 0,245 y 0,32 s y reaparecen a los 2,4 s desde la activación.
- Los enemigos anuncian embestidas o disparos en amarillo. Los blindados reducen golpes frontales: flanquea o rompe la guardia con I. Los jefes solo reciben daño en verde y encadenan dos ataques en segunda fase.
- Los impactos normales quitan 2 de los 6 puntos de energía; las embestidas blindadas quitan 3. La protección tras recibir daño dura 0,55 s. El dash permite esquivar, pero no da inmunidad.
- Morir reinicia enemigos, proyectiles, plataformas y secuencias parciales. Conserva mecanismos resueltos, historia vista y registros. Los jefes derrotados permanecen derrotados.
- **Continuar sesión** conserva el progreso mientras el juego está abierto. **No hay guardado en disco**. Nueva partida reinicia todo.
- El selector de desarrollo reinicia mecanismos y checkpoint de la sección elegida; conserva el archivo narrativo de la sesión. Usa Nueva partida para volver a ver toda la historia.

## Editar

Abre cualquier `levels/Level_X_Y.tscn`. Cada escena contiene geometría y entidades reales editables: no se construye al iniciar el juego.

- **Geometry:** plataformas y suelo con colisión; cada bloque tiene `Blockout` y `Surface` como arte provisional.
- **Entities:** instancias de terminales, checkpoints, peligros, plataformas, puertas, enemigos y jefes. Sus parámetros se editan en el Inspector.
- **BackgroundArt / WorldArt / ForegroundArt / Audio:** puntos de integración para las próximas capas.
- **Player:** instancia compartida de `scenes/player/player.tscn` con su cámara.
- **Labels:** carteles provisionales de diseño y aprendizaje.

Los objetivos y orden de escenas están en `data/sections.json`; los diálogos, eventos, registros y cinemáticas en `data/narrative.json`. La historia usa **STORY_01–STORY_20** y los registros canónicos **REG_01–REG_06**, además de tres fragmentos opcionales.

Consulta [el mapa completo y la guía de producción](docs/BOCETO_JUGABLE.md), [la guía de sprites](docs/GUIA_SPRITES.md) y [la comparación con el HTML](docs/CONTROL_LABORATORIO.md).

`tools/build_campaign.py` fue la herramienta de autoría inicial. **No es necesaria para jugar**. Volver a ejecutarla reemplaza los niveles, entidades y JSON generados: guarda tus ediciones manuales antes de regenerar.

## Verificar

Ejecuta **VERIFICAR_PROYECTO.bat**. Importa los recursos y ejecuta seis comprobaciones:

1. `tests/smoke_test.gd`: 74 fotogramas actuales, carrera, salto, combos y galería.
2. `tests/campaign_test.gd`: 12 secciones, dependencias, checkpoints, puzle, daño a jefes, fases, puertas persistentes, 20 eventos principales y regreso del epílogo al menú.
3. `tests/traversal_test.gd`: 175 comprobaciones con física real; incluye los 37 cruces con dash, sus intentos sin dash, descenso, embarque y desembarque.
4. `tests/lab_parity_test.gd`: 8 escenarios / 960 fotogramas de movimiento comparados con el HTML. El combate actual usa hojas de nueve celdas y ya no se compara con los ataques antiguos.
5. `tests/lab_integration_test.gd`: las ocho trazas mediante el jugador real y la secuencia de impactos 25/45/60 del combo actual.
6. `tests/challenge_combat_test.gd`: aviso antes del daño, esquivas, guardia, fuerte, tirador, cadenas de jefe, carga aérea y colapso de plataformas.

Las pruebas de recorrido desactivan las amenazas para aislar los saltos. Las de campaña invocan interacciones y simulan condiciones de combate; no sustituyen una partida humana completa para ajustar dificultad y ritmo. Las capturas de las 12 secciones se revisan con `tests/capture_campaign.gd`, ejecutado con renderizado.

`tests/display_test.gd` se ejecuta con renderizado y verifica 1920×1080, 1280×720, 960×540, 800×600 y 640×360, incluyendo menú, selector, HUD, diálogos, laboratorio, galería y F11. Guarda las capturas en `.local/1080-*.png`. Ejemplo: `godot --path . --resolution 1920x1080 --script res://tests/display_test.gd`.

## Alcance y créditos

La aventura está conectada de principio a fin como boceto. El personaje incorpora efectos y sonidos sintetizados a partir del laboratorio. Quedan pendientes el arte final, la música y el audio ambiental, el balance fino y la duración definitiva. No se ha medido ni prometido todavía una partida de 60–90 minutos.

Sprites del paquete suministrado: **Ozzbit Games**. Su licencia de uso personal no comercial y crédito obligatorio se conserva en `assets/licenses/`. Los originales del escritorio no se han modificado. El guion y el encargo originales están en `docs/references/`.

Existe una copia de la base previa a la aventura en `.local/antes-aventura-*`. `.local/`, `.godot/` y exportaciones están excluidos por `.gitignore`. No se han publicado cambios ni subido archivos a GitHub.
