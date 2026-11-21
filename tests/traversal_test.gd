extends SceneTree
## Usa la física REAL del jugador para comprobar cada conexión entre islas.
## Las amenazas se desactivan aquí; el combate se prueba por separado.
var gm: Node
var ui: Node
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func frame() -> void:
	await physics_frame
	await process_frame

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)
	else:
		print("OK: ", label)

func reset_input() -> void:
	for action in ["move_left", "move_right", "jump", "dash"]:
		Input.action_release(action)

func jump_between(player, start: Rect2, target: Rect2, direction: float, use_dash := false) -> bool:
	reset_input()
	player.motion = load("res://scripts/player/lab_motion.gd").new()
	player.previous_keys.clear()
	var rise := start.position.y - target.position.y
	var gap := target.position.x - start.end.x if direction > 0.0 else start.position.x - target.end.x
	var launch := 46.0 if rise > 20.0 and gap < 20.0 else 18.0
	player.position = Vector2(start.end.x - launch if direction > 0.0 else start.position.x + launch, start.position.y - 0.2)
	player.velocity = Vector2.ZERO
	player.sprite.play("idle")
	for i in range(3):
		await frame()
	player.velocity.x = 210.0 * direction
	Input.action_press("move_right" if direction > 0.0 else "move_left")
	if not (target.size.x == 64 and rise < 0): Input.action_press("jump")
	var landed := false
	for i in range(95):
		if use_dash and i == 20: Input.action_press("dash")
		if i == 21: Input.action_release("dash")
		await frame()
		if target.size.x < 200.0 and (player.position.x - (target.get_center().x - direction * 18.0)) * direction > 0.0:
			Input.action_release("move_right")
			Input.action_release("move_left")
		if player.position.y > maxf(start.position.y, target.position.y) + 180:
			break
		if player.is_on_floor() and absf(player.position.y - target.position.y) < 3.0 and player.position.x >= target.position.x - 8 and player.position.x <= target.end.x + 8:
			landed = true
			break
	reset_input()
	return landed

func run() -> void:
	gm = root.get_node("GameManager")
	ui = root.get_node("GameUI")
	gm.instant_transitions = true
	for index in range(12):
		gm.goto_section(index, true)
		for i in range(10):
			await frame()
		ui.clear_dialogues()
		gm.campaign_active = false
		var level := current_scene
		var player = level.get_node("Player")
		player.respawn_y = 10000.0
		for entity in level.get_node("Entities").get_children():
			if entity.get_script() != load("res://scripts/entities/moving_platform.gd"):
				entity.set_process(false)
				entity.set_physics_process(false)
			if entity.get_script() == load("res://scripts/entities/door.gd"):
				entity.get_node("CollisionShape2D").disabled = true
		var main: Array[Rect2] = []
		var islands: Array[Rect2] = []
		for block in level.get_node("Geometry").get_children():
			var size: Vector2 = block.get_node("CollisionShape2D").shape.size
			if size.x > 24:
				var rect := Rect2(block.position, size)
				islands.append(rect)
				if block.get_meta("route_surface", false):
					main.append(rect)
		for i in range(main.size() - 1):
			var start := main[i]
			var target := main[i + 1]
			var direction := 1.0 if target.get_center().x > start.get_center().x else -1.0
			var gap := target.position.x - start.end.x if direction > 0.0 else start.position.x - target.end.x
			if gap <= 100.0 or (index != 8 and gap <= 230.0):
				check(await jump_between(player, start, target, direction, gap>170), "%d.%d conexión %d%s" % [index / 3 + 1, index % 3 + 1, i + 1," DASH" if gap>170 else ""])
				if gap>170:
					check(not await jump_between(player,start,target,direction),"Cruce exige dash %d/%d" % [index,i])
			elif index == 8:
				# Los descansos del descenso permiten pasar por una repisa central.
				var bridge := Rect2(708, (start.position.y + target.position.y) / 2.0, 64, 12)
				check(await jump_between(player, start, bridge, direction), "3.3 repisa central %d" % i)
				check(await jump_between(player, bridge, target, direction), "3.3 salida de repisa %d" % i)
			else:
				var carrier: Node2D
				for entity in level.get_node("Entities").get_children():
					if entity.get_script() == load("res://scripts/entities/moving_platform.gd") and entity.origin.x >= start.end.x and entity.origin.x < target.position.x:
						carrier = entity
				if not is_instance_valid(carrier):
					check(false, "Falta plataforma para conexión %d/%d" % [index, i])
					continue
				carrier.elapsed = 0.0
				await frame()
				# El primer salto se evalúa con el transporte en el extremo cercano.
				var initial: Vector2 = carrier.origin
				carrier.set_physics_process(false)
				carrier.position = initial
				await frame()
				check(await jump_between(player, start, Rect2(initial, Vector2(carrier.width, 12)), 1.0), "%d embarque" % index)
				if not carrier.unstable:
					player.position = initial + Vector2(carrier.width * 0.5, -0.2)
					player.velocity = Vector2.ZERO
					for j in range(3): await frame()
					var before: Vector2 = player.position
					carrier.set_physics_process(true)
					for j in range(int(carrier.duration * 30)):
						await frame()
					check(player.position.x > before.x + carrier.travel.x * 0.7, "%d transporte mantiene al jugador" % index)
					carrier.set_physics_process(false)
				check(await jump_between(player, Rect2(carrier.position, Vector2(carrier.width, 12)), target, 1.0), "%d desembarque" % index)
		reset_input()
	print("RECORRIDOS: ", checks, " comprobaciones, ", failures, " fallos")
	quit(0 if failures == 0 else 1)
