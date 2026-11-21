extends SceneTree
const Motion = preload("res://scripts/player/lab_motion.gd")
var failures := 0
const MOVEMENT_CASES := ["aceleracion_frenado_giro","stick_y_modificador","salto_completo","salto_corto","coyote","buffer_aterrizaje","dash_suelo_y_recarga","dash_aereo"]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var cases: Array = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/lab_traces.json"))
	var total := 0
	for scenario in cases:
		# Las hojas de combate actuales tienen nueve celdas; ya no son el HTML.
		if scenario.name not in MOVEMENT_CASES: continue
		var motor = Motion.new()
		for key in scenario.initial: motor.set(key,scenario.initial[key])
		var hits: Array[int] = []
		var case_failed := false
		for index in range(scenario.steps.size()):
			var step: Dictionary = scenario.steps[index]
			# Reconstruye la fracción original: el parser JSON redondea decimales largos.
			var dt: float = 1.0 / step.rate
			motor.events.clear()
			match step.command:
				"forceCombo1": motor.force_combo("combo_1")
				"forceCombo2": motor.force_combo("combo_2")
				"forceCombo3": motor.force_combo("combo_3")
				"forceComboEnd": motor.force_combo("combo_1_end")
			motor.before_move(dt,step.input)
			motor.integrate_reference(dt,scenario.platforms)
			motor.choose_state(step.input)
			if motor.active_hit() and motor.sword_rect().intersects(Rect2(scenario.dummy_x-12,355,24,45)):
				hits.append(motor.damage())
				motor.combo_hit_done = true
			motor.animate(dt)
			for key in step.expected:
				var actual: Variant = motor.get(key)
				var expected: Variant = step.expected[key]
				var equal: bool
				if typeof(expected) == TYPE_FLOAT or typeof(expected) == TYPE_INT:
					equal = absf(float(actual)-float(expected)) < 0.000001
				else: equal = actual == expected
				if not equal:
					push_error("%s frame %d %s: Godot=%s HTML=%s" % [scenario.name,index,key,str(actual),str(expected)])
					case_failed = true
					break
			var expected_hits: Array[int] = []
			expected_hits.assign(step.hits)
			if hits != expected_hits:
				push_error("Daños distintos: " + scenario.name + " frame " + str(index))
				case_failed = true
			if case_failed: break
			total += 1
		if case_failed: failures += 1
		else: print("OK HTML/GODOT: ",scenario.name)
	print("PARIDAD MOVIMIENTO: ",MOVEMENT_CASES.size()," escenarios, ",total," fotogramas, ",failures," fallos; combate actual verificado por separado")
	quit(0 if failures == 0 else 1)
