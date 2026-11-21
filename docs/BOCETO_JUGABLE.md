# KORA / Mapa del boceto conectado

## Estado de la aventura

Flujo: `MainMenu` → `Prologue` → `Level_1_1` … `Level_4_3` → `Epilogue` → `MainMenu`.

Las 12 secciones tienen suelo, colisiones, objetivos, salida condicionada, checkpoints y cámara propia. Las distancias están expresadas en píxeles de mundo, con sprites a escala original. No representan minutos garantizados de juego.

| Escena | Extensión | Estructura y contenido jugable | Checkpoints |
|---|---:|---|---:|
| Prólogo | 4 pasos manuales | Patrón corta-larga-corta, fecha +31 horas, aproximación, descarga defensiva e impacto. Puede omitirse. | — |
| 1.1 / La nave destruida | 4.800 px | Cráter seguro, nave, telemetría, fragmento opcional, célula, subida al mirador, restos peligrosos y salida. | 3 |
| 1.2 / El primer contacto | 5.200 px | Encuentro con SIL, fauna provisional, ruta alta opcional, primer combate territorial, fragmentos y resonador subterráneo. | 3 |
| 1.3 / La grieta luminosa | 5.000 px; descenso de 240 px | Repisas, transporte móvil, pilar de Resonancia, paso inestable, peligro cíclico, muestra limitada y estructura lejana. | 4 |
| 2.1 / Jardines de cristal | 5.600 px | SIL, jardín oeste, desvío Eshar, cauce móvil, jardín este, defensa territorial y apertura del santuario. | 3 |
| 2.2 / El santuario silencioso | 5.000 px | Ruinas, inscripción, memoria lateral, tres resonadores, puerta, archivo de Ayen y acceso al guardián. | 3 |
| 2.3 / El guardián del bosque | 4.400 px | Aproximación, peligros, preparación, arena cerrada de ORÚ, dos fases, autorización y descenso. | 2 |
| 3.1 / Cavernas de resonancia | 5.600 px; desniveles | Saltos con descargas, criatura liberable opcional, transporte, inscripción lateral, regulador y complejo. | 3 |
| 3.2 / El complejo abandonado | 6.200 px | Vigilia, cámaras de memorias, Ayen, sacrificio de Saren, dos registros opcionales, historial de señales y redirección. | 3 |
| 3.3 / El descenso | 1.500 × 2.520 px; caída neta de 1.920 px | Zigzag vertical, repisas intermedias, ascensores laterales, descansos, conducto, registro Saren y eco de la propia voz. | 5 |
| 4.1 / La zona corrompida | 6.200 px | Conducto, tres estabilizadores, fauna resistente, descargas, plataformas móviles e inestables, puerta al núcleo. | 3 |
| 4.2 / La cámara del núcleo | 5.000 px | Galería de ecos, última grabación, consola, núcleo visible, transmisor de fase, nota oculta y último descanso. | 3 |
| 4.3 / El corazón fracturado | 5.400 px | Aproximación, arena de Saren, dos fases, conversación posterior, liberación, envío de la señal y estabilización. | 2 |
| Epílogo | 5 pasos manuales | Recuperación, despedida de SIL, reparación y despegue, segunda señal distante, créditos y vuelta al menú. | — |

Hay **37 checkpoints**. Las secciones horizontales ocupan aproximadamente 7–10 anchos de pantalla de 640 px. El descenso usa varias alturas y descansos visibles. Las zonas tranquilas de investigación alternan con obstáculos y encuentros. El ritmo se debe ajustar jugando: la extensión del boceto no equivale al objetivo final de duración del guion.

## Sistemas y archivos

| Sistema | Archivo principal | Responsabilidad |
|---|---|---|
| Sesión | `autoload/game_manager.gd` | Salud, sección, checkpoints, mecanismos, niveles completados y fundidos. |
| Narrativa | `autoload/narrative_manager.gd` | Eventos vistos y registros, separados de enemigos y temporizadores. |
| Interfaz | `autoload/game_ui.gd` | HUD, interacción, diálogo manual o en movimiento, pausa, archivo, jefe y selector F1. |
| Personaje | `scripts/player/player.gd` | Movimiento previo conservado; espada por fotograma, daño, invulnerabilidad y recuperación. |
| Sección | `scripts/world/section.gd` | Cámara, entrada, fondo provisional y secuencia de resonadores. |
| Datos | `data/sections.json`, `data/narrative.json` | Orden, objetivos, textos, registros, prólogo y epílogo. |
| Piezas | `scenes/entities/*.tscn` | Checkpoint, Hazard, MovingPlatform, InteractiveTerminal, CrystalSwitch, EnergyDoor, LevelExit, BaseEnemy, Boss, StoryTrigger y Decoration. |

El explorador usa el controlador traducido del laboratorio HTML: 210 px/s con A/D o flechas, caminar analógico, dash de 520 px/s y modificador Shift/LB. Mantiene impulso de salto 380 px/s, gravedad 950 px/s², colisión 26 × 38, anclaje (64,80), coyote time 0,1 s y buffer 0,12 s. La campaña exigente requiere salto con dash en 37 cruces y permite un dash aéreo por salto; consulta RETO_EXIGENTE.md.

Los combos actuales usan nueve celdas por golpe, con daños 25 / 45 / 60. El envaine ya no golpea. Duelistas, tiradores y blindados exigen esquivar, flanquear y romper guardias; los jefes encadenan dos ataques antes de abrirse en segunda fase. Sus parámetros y pruebas están en RETO_EXIGENTE.md.

ORÚ anticipa ataques cercanos y ondas saltables. Saren añade proyectiles dirigidos a una posición anunciada y marcas terrestres; su segunda fase acelera las ventanas y vuelve inestables las plataformas de la arena. La recuperación verde es la ventana de daño. Los reguladores y decoraciones definitivas del guion se pueden ampliar sobre esta arena.

## Progreso, muerte y selección de pruebas

- Hay 6 puntos de salud y 0,55 s de invulnerabilidad tras recibir daño. Morir o pulsar R recarga desde el checkpoint.
- Cada sección guarda sus mecanismos. La recarga limpia enemigos vivos, proyectiles, ciclos, posición de plataformas y secuencia incompleta de resonadores.
- Puertas resueltas y jefes derrotados permanecen resueltos. Diálogos vistos y registros no se borran al morir.
- La secuencia del santuario es **I → III → II**, visible en cartel e inscripción. Un error reinicia sin daño.
- Los requisitos principales se revisan en las interacciones y en la salida. Ningún registro opcional es requisito.
- La salida requiere F: no teletransporta por pasar cerca. E ejecuta el dash.
- F1 permite iniciar cualquier sección con mecanismos y checkpoint limpios. No necesita resolver las anteriores. Los eventos vistos siguen marcados durante la sesión.
- Continuar conserva la sesión; cerrar la aplicación la termina. El guardado a disco es una ampliación posterior.

## Hilo narrativo

| Evento | Activación |
|---|---|
| STORY_01 / Accidente | Terminar u omitir el prólogo. |
| STORY_02 / Descarga | Telemetría, 1.1. |
| STORY_03 / SIL | Primer contacto, 1.2. |
| STORY_04 / Señal subterránea | Resonador al final de 1.2. |
| STORY_05 / Resonancia | Pilar, 1.3. |
| STORY_06 / Santuario | Apertura alimentada por ambos jardines, 2.1. |
| STORY_07 / KORA | Ayen tras el puzle, 2.2. |
| STORY_08 / ORÚ | Derrota del guardián, 2.3. |
| STORY_09 / Profundidades | Entrada a 3.1. |
| STORY_10 / Vigilia | Archivo principal, 3.2. |
| STORY_11 / Fractura | Advertencia de Ayen, 3.2. |
| STORY_12 / Sacrificio | Archivo de Saren, 3.2. |
| STORY_13 / Voz propia | Eco del conducto, 3.3. |
| STORY_14 / Núcleo | Entrada a 4.2. |
| STORY_15 / Revelación temporal | Transmisor, 4.2. |
| STORY_16 / Confrontación | Activación de la arena de Saren, 4.3. |
| STORY_17 / Liberación | Consola, después del combate. |
| STORY_18 / Señal | Transmisor, después de liberar memorias. |
| STORY_19 / Recuperación | Estabilizador, después de enviar la señal. |
| STORY_20 / Segunda señal | Últimos pasos del epílogo. |

Registros: REG_01 en 2.1; REG_02 en 2.2; REG_03 y REG_04 en 3.2; REG_05 en 3.3; REG_06 en 4.2. Fragmentos adicionales: REG_SIGNAL en 1.1, REG_VOICE en 1.2 y REG_INSCRIPTION en 3.1. Se releen desde Tab.

Los textos adaptan brevemente el documento maestro; no implementan cada intervención del guion largo. Conservan la causa de la Fractura, el sacrificio de Saren, la diferencia entre señal y descarga, las restricciones del Eco de Fase y el origen de la señal en el protagonista.

## Capas pendientes por sección

En **todas** las secciones quedan por añadir o pulir TileMapLayer/texturas finales, escenarios, enemigos animados, parallax, iluminación, partículas y audio. Los marcadores actuales aportan forma y función, sin fingir arte definitivo.

| Sección | Próxima capa específica |
|---|---|
| Prólogo | Nave, planeta, interferencias, impacto y motivo sonoro corta-larga-corta. |
| 1.1 | Cráter, restos y módulos de nave, polvo, paisaje y equipo recuperable. |
| 1.2 | Vegetación, fauna, animaciones de SIL y criatura territorial. |
| 1.3 | Fondo profundo, cristales, ascensores Eshar y partículas de Resonancia. |
| 2.1 | Jardines vivos/apagados, árboles cristalinos y respuesta visual de los circuitos. |
| 2.2 | Arquitectura, símbolos, resonadores y holograma/retrato de Ayen. |
| 2.3 | ORÚ, ataques animados, barreras, autorización y transición de descenso. |
| 3.1 | Cavernas, descargas, criatura debilitada y liberación animada. |
| 3.2 | Laboratorios, cámaras de memoria, archivos holográficos y maquinaria. |
| 3.3 | Parallax vertical, estructuras, elevadores, derrumbes y voz distorsionada. |
| 4.1 | Cristales fracturados, corrupción energética, fauna y estabilizadores. |
| 4.2 | Núcleo monumental, galería de ecos, Ayen y transmisor de fase. |
| 4.3 | Saren, ataques, liberación de ecos, señal y estabilización. |
| Epílogo | Recuperación, despedida de SIL, reparación, despegue y créditos finales. |

## Sustituir el boceto por arte

1. Trabaja en una sección a la vez; conserva Player y las claves de mecanismos mientras cambias el arte.
2. Añade fondos a BackgroundArt y decoraciones a WorldArt. Puedes desactivar `show_blockout_backdrop` en el nodo de nivel.
3. Sustituye `Blockout`/`Surface` por TileMapLayer o sprites. Conserva las colisiones hasta validar el nuevo suelo; si el TileMap tiene colisiones, elimina las duplicadas.
4. Añade sprites finales como hijos de las entidades reutilizables. Su lógica usa la raíz y parámetros exportados, no el arte.
5. Conserva `state_key`, `required_keys`, `story_id` y `record_id` o actualiza sus referencias conjuntamente en datos y escenas.
6. Ejecuta la sección con F6, el flujo completo con F5 y las pruebas con VERIFICAR_PROYECTO.bat.

No regeneres con `build_campaign.py` después de editar a mano sin conservar esos cambios. El juego carga directamente los .tscn; el generador no forma parte de la ejecución.

## Alcance de la verificación

Las pruebas verifican carga y referencias, condiciones de progreso, física original, golpes, segunda fase, persistencia tras muerte y 175 comprobaciones de recorrido entre superficies con el controlador real. Las pruebas de salto frenan sobre plataformas estrechas; los peligros se desactivan únicamente en esa prueba para aislar la geometría.

Se revisaron capturas renderizadas de las 12 secciones, menú, selector, diálogos y epílogo. Esto no equivale a una partida humana continua de 60–90 minutos. Quedan por ajustar dificultad, colocación fina, duración de diálogos y ritmo con pruebas humanas sobre el lienzo conectado.
