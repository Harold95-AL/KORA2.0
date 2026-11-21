extends SceneTree
## Reproduce las trazas del HTML a través del jugador, sprites, saco y efectos reales.
const Motion = preload("res://scripts/player/lab_motion.gd")
const MOVEMENT_CASES = preload("res://tests/lab_parity_test.gd").MOVEMENT_CASES
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var lab = load("res://scenes/lab/reference_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	var player = lab.player
	player.set_physics_process(false)
	player.effects.set_physics_process(false)
	lab.dummy.set_physics_process(false)
	var cases: Array = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/lab_traces.json"))
	for scenario in cases:
		if scenario.name not in MOVEMENT_CASES: continue
		player.motion = Motion.new()
		for key in scenario.initial: player.motion.set(key,scenario.initial[key])
		player.position = Vector2(player.motion.x,player.motion.y)
		player.velocity = Vector2(player.motion.vx,player.motion.vy)
		player.reference_platforms.assign(scenario.platforms)
		lab.dummy.position = Vector2(scenario.dummy_x,400)
		lab.dummy.health = 100
		for index in range(scenario.steps.size()):
			var step = scenario.steps[index]
			match step.command:
				"forceCombo1": player.force_combo("combo_1")
				"forceCombo2": player.force_combo("combo_2")
				"forceCombo3": player.force_combo("combo_3")
				"forceComboEnd": player.force_combo("combo_1_end")
			player.step_motion(1.0/step.rate,step.input)
			player.effects._physics_process(1.0/step.rate)
			lab.dummy._physics_process(1.0/step.rate)
			var health := 100
			for hit in step.hits:
				health -= int(hit)
				if health <= 0: health = 100
			if player.position.distance_to(Vector2(step.expected.x,step.expected.y)) > 0.01 or player.sprite.animation != step.expected.state or player.sprite.frame != int(step.expected.frame_index) or lab.dummy.health != health:
				push_error("Integración HTML: %s / frame %d; posición %s, sprite %s/%d, saco %d (esperado %d)" % [scenario.name,index,player.position,player.sprite.animation,player.sprite.frame,lab.dummy.health,health])
				failures += 1
				break
	# Contrato de los combos actuales: tres impactos, sin repetir daño ni
	# impacto adicional de envaine. El saco se recoloca para aislar las ventanas.
	player.motion = Motion.new()
	player.position = Vector2(0,400)
	player.velocity = Vector2.ZERO
	player.reference_platforms.assign([{"x":-1000,"y":400,"w":2000}])
	lab.dummy.health = 1000 # Evitar el reinicio del saco para medir los tres daños.
	var damages: Array[int] = []
	for tick in range(100):
		lab.dummy.position = player.position+Vector2(35,0)
		var before: int = lab.dummy.health
		player.step_motion(1.0/60.0,{"attack_pressed": tick in [2,8,26]})
		if lab.dummy.health != before:
			damages.append(before-lab.dummy.health if lab.dummy.health!=100 else before)
	if damages != [25,45,60] or player.motion.state!="idle":
		push_error("Combo actual: impactos incorrectos " + str(damages))
		failures += 1
	print("INTEGRACIÓN: ",MOVEMENT_CASES.size()," trazas de movimiento + combo actual, ",failures," fallos")
	lab.free()
	quit(0 if failures == 0 else 1)
