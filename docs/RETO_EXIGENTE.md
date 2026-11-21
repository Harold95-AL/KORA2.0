# Campaña exigente

El reto es la dificultad predeterminada de las doce secciones. Se conserva el recorrido narrativo, el puzle y los checkpoints, con reintentos que mantienen los mecanismos resueltos. No hay un multiplicador exponencial literal: la dificultad aumenta mediante geometría, tiempos, patrones y daño.

## Plataformeo

- 37 nuevos cruces de 192 / 208 / 218 / 230 px, según el capítulo. Requieren impulso de carrera, salto mantenido y dash en el aire. La prueba verifica cada cruce con dash y comprueba el fallo del salto normal.
- Un dash aéreo por salto en campaña; tocar suelo lo recupera. Se conserva la velocidad 520 px/s, duración 0,22 s y recarga 0,40 s. El HUD indica si está listo, enfriándose o requiere aterrizar.
- Cámara adelantada 70 px hacia donde miras para ver el borde de llegada antes de saltar. Interpolación, velocidad y salto del personaje conservados.
- Transportes de 64 px al inicio y 56 px después, con recorridos un 35 % más rápidos en duración. Los apoyos inestables colapsan tras 0,32 / 0,295 / 0,27 / 0,245 s; una barra roja muestra el margen restante. Reaparecen a los 2,4 s desde su activación.
- El descenso mantiene la serpentina, con repisas centrales de 64 px, pulsos alternados y enemigos. Para bajar a la repisa próxima puede convenir dejarse caer en lugar de saltar hacia la superior.
- 40 peligros: ventanas de reposo cortas, aviso amarillo visible y descarga prolongada. Los peligros que dependían de un mecanismo siguen apagándose al resolverlo.

## Combate

49 enemigos repartidos por la campaña:

- Duelistas: fijan la dirección, avisan durante 0,55 s y embisten a 380 px/s. Desde el capítulo 2 pueden atacar dos veces; el segundo aviso dura 0,38 s.
- Tiradores: fijan su puntería durante el aviso, con línea visible y proyectiles de 300 px/s. Reaccionan a saltos o dashes que ocurran después de apuntar. No disparan a través de paredes.
- Blindados: embestida a 310 px/s y aviso de 0,66 s. La guardia frontal reduce el daño ligero al 25 %. Un fuerte de 60 rompe la guardia y deja 0,85 s de apertura; atacar por detrás ignora la defensa.

Los impactos normales y los peligros causan 2 puntos; el blindado causa 3. El jugador tiene 6 de energía y 0,55 s de protección después de recibir daño. **El dash no da invulnerabilidad**: hay que salir del área o trayectoria anunciada. Los enemigos no giran su ataque instantáneamente para seguirte.

ORÚ tiene 450 de salud y Saren 720. Alternan golpe de proximidad de 150 px, ondas rápidas y marca de 112 px a cada lado del punto fijado. La marca da 0,50 s: correr desde el centro no basta, el dash sí. Saren añade abanicos de tres proyectiles. En segunda fase encadenan dos patrones, las ondas se repiten y las plataformas de Saren se vuelven inestables. Las ventanas verdes duran 0,95 s en primera fase y 0,70 s en segunda: entrar, golpear y salir es más seguro que terminar siempre el combo.

Se conservaron las animaciones de combate de nueve celdas que ya estaban presentes al retomar este trabajo: 22/22/20 FPS, primer combo desde la celda 3 y fuerte que vuelve directamente a reposo/caída. El envaine actual no hace daño. No se restauró el combate antiguo del HTML.

## Autoría y comprobación

Las escenas siguen siendo editables en Godot. `tools/hard_campaign.py` aplica el diseño a la base de `build_campaign.py` antes de guardarlas. Al regenerar, protege el apoyo de objetivos/checkpoints y evita colocar huecos bajo las rutas superiores o dentro de las arenas. `data/dash_routes.json` documenta los cruces y `data/challenge_manifest.json` cuenta enemigos y peligros por sección.

Para regenerar solo niveles y catálogo, desde la raíz:

```powershell
python -c "import sys; sys.path.insert(0, 'tools'); import build_campaign; build_campaign.levels()"
```

Esto reemplaza las escenas de nivel: conserva tus ediciones manuales antes de hacerlo. La copia anterior a este trabajo está en `.local/antes-reto-20261120-203429`.

`VERIFICAR_PROYECTO.bat` ejecuta seis suites. Se comprueban las doce secciones, apoyo físico de objetivos y checkpoints, puertas y progreso; 175 comprobaciones de recorrido; combate y esquiva con el jugador real; colapso/reaparición; animaciones actuales y 960 fotogramas de movimiento del HTML. La comparación histórica del combate HTML se excluye explícitamente porque tus hojas y ventanas actuales son distintas; sus trazas originales permanecen intactas.

Las pruebas de recorrido aíslan la geometría desactivando amenazas, y las de combate comprueban situaciones concretas. No equivalen a una partida humana completa: queda por ajustar la dificultad percibida, especialmente la combinación de enemigos y pulsos durante el descenso. Las capturas renderizadas permiten revisar encuadre y avisos, no medir ese balance por sí solas.
