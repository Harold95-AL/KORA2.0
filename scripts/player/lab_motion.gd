extends RefCounted
## Traducción del objeto player de lab_reference.html. Sin dependencias de escena.
## Orden conservado: entradas → física → colisiones → impactos → estados → reloj.
const FRAMES := {"idle": 10, "walk": 10, "run": 10, "dash": 9, "design": 1, "jump": 6, "fall": 4, "fall_loop": 3, "combo_1": 9, "combo_2": 9, "combo_3": 9, "combo_1_end": 4}
const FPS := {"idle": 8.0, "walk": 10.0, "run": 14.0, "dash": 18.0, "design": 1.0, "jump": 12.0, "fall": 12.0, "fall_loop": 10.0, "combo_1": 22.0, "combo_2": 22.0, "combo_3": 20.0, "combo_1_end": 12.0}
var walk_speed := 110.0
var run_speed := 210.0
var jump_force := 380.0
var gravity := 950.0
var coyote_max := 0.1
var buffer_max := 0.12
var x := 0.0
var y := 400.0
var vx := 0.0
var vy := 0.0
var facing := 1
var grounded := false
var state := "idle"
var frame_index := 0
var anim_timer := 0.0
var coyote_timer := 0.0
var jump_buffer := 0.0
var attack_buffered := false
var combo2_buffered := false
var combo3_buffered := false
var combo_hit_done := false
var is_dashing := false
var dash_timer := 0.0
var dash_cooldown := 0.0
var combo_prompt := ""
var prompt_timer := 0.0
var force_state := "none"
var events: Array[Dictionary] = []
var attacking_this_step := false
var fps_overrides := {"idle": 8.0, "walk": 10.0, "run": 14.0}

func emit(kind: String, values: Dictionary = {}) -> void:
	values["type"] = kind
	values["position"] = Vector2(x, y)
	values["state"] = state
	values["frame"] = frame_index
	values["facing"] = facing
	events.append(values)

func set_state(next: String) -> void:
	if state == next:
		return
	if state == "combo_1" and next not in ["combo_2", "combo_3"]:
		combo2_buffered = false
		combo3_buffered = false
	if state == "combo_2" and next != "combo_3":
		combo3_buffered = false
		attack_buffered = false
	state = next
	frame_index = mini(3, FRAMES[next] - 1) if next == "combo_1" else 0
	anim_timer = 0.0
	combo_hit_done = false

func is_attacking() -> bool:
	return state in ["combo_1", "combo_2", "combo_3", "combo_1_end"]

func prompt(text: String, duration: float) -> void:
	combo_prompt = text
	prompt_timer = duration

func rumble(duration: float, weak: float, strong: float) -> void:
	emit("rumble", {"duration": duration, "weak": weak, "strong": strong})

func dash() -> void:
	if dash_cooldown > 0.0 or is_dashing:
		return
	is_dashing = true
	dash_timer = 0.22
	dash_cooldown = 0.4
	vx = facing * 520.0
	vy = 0.0
	set_state("dash")
	prompt("DASH ASTRAL", 0.45)
	emit("dash")
	emit("dust")
	emit("ghost")
	rumble(0.06, 0.4, 0.8)

func attack() -> void:
	if state == "combo_1":
		combo2_buffered = true
		prompt("SEGUNDO GOLPE PREPARADO", 0.75)
	elif state == "combo_2":
		combo3_buffered = true
		prompt("REMATE PREPARADO", 0.75)
	elif state not in ["combo_3", "combo_1_end"]:
		set_state("combo_1")
		vx = facing * 120.0
		prompt("COMBO 1 · J/X: tajo 2 · I/Y: fuerte", 0.75)
		emit("slash", {"pitch": 1.0})
		rumble(0.05, 0.4, 0.7)

func heavy_attack() -> void:
	if state in ["combo_1", "combo_2"]:
		combo3_buffered = true
		prompt("GOLPE CONTUNDENTE PREPARADO", 0.85)
		rumble(0.06, 0.5, 0.8)
	elif state not in ["combo_3", "combo_1_end"]:
		set_state("combo_3")
		vx = facing * 180.0
		prompt("GOLPE CONTUNDENTE ASTRAL", 0.85)
		emit("slash", {"pitch": 0.85})
		rumble(0.08, 0.5, 0.9)

func force_combo(next: String) -> void:
	set_state(next)
	vx = facing * {"combo_1": 120.0, "combo_2": 160.0, "combo_3": 180.0, "combo_1_end": 140.0}[next]
	prompt(next.to_upper(), 0.8)
	emit("slash", {"pitch": {"combo_1": 1.0, "combo_2": 1.35, "combo_3": 0.85, "combo_1_end": 1.1}[next]})
	if next == "combo_3": emit("shake", {"duration": 0.25, "intensity": 6.0})

func before_move(dt: float, input: Dictionary) -> void:
	if prompt_timer > 0.0:
		prompt_timer -= dt
		if prompt_timer <= 0.0: combo_prompt = ""
	if dash_cooldown > 0.0: dash_cooldown -= dt
	if input.get("dash_pressed", false): dash()
	if is_dashing:
		dash_timer -= dt
		vx = facing * 520.0
		vy = 0.0
		emit("dash_tick")
		if dash_timer <= 0.0: is_dashing = false
	if input.get("attack_pressed", false): attack()
	if input.get("heavy_pressed", false): heavy_attack()
	attacking_this_step = is_attacking()
	if not attacking_this_step and not is_dashing:
		var target_vx := 0.0
		var axis: float = input.get("move_x", 0.0)
		if absf(axis) > 0.05:
			facing = 1 if axis > 0.0 else -1
			var running: bool = input.get("is_running", false) or absf(axis) >= 0.75
			target_vx = axis * (run_speed if running else walk_speed)
		var acceleration := 22.0 if grounded else 12.0
		vx += (target_vx - vx) * minf(1.0, acceleration * dt)
	elif not is_dashing:
		vx += (0.0 - vx) * 6.0 * dt
	if not grounded and not is_dashing:
		vy += gravity * (0.45 if attacking_this_step else 1.0) * dt
		coyote_timer -= dt
	elif grounded:
		coyote_timer = coyote_max
	if input.get("jump_pressed", false) and not attacking_this_step:
		jump_buffer = buffer_max
	elif jump_buffer > 0.0:
		jump_buffer -= dt
	if jump_buffer > 0.0 and (grounded or coyote_timer > 0.0) and not attacking_this_step:
		vy = -jump_force
		grounded = false
		coyote_timer = 0.0
		jump_buffer = 0.0
		set_state("jump")
		emit("dust")
		emit("jump")
		rumble(0.05, 0.2, 0.4)
	if not input.get("jump_held", false) and vy < -120.0:
		vy += 650.0 * dt

func integrate_reference(dt: float, platforms: Array) -> void:
	x += vx * dt
	y += vy * dt
	var on_ground := false
	for platform in platforms:
		var prev_y := y - vy * dt
		if x >= platform["x"] and x <= platform["x"] + platform["w"]:
			if prev_y <= platform["y"] + 2.0 and y >= platform["y"] and vy >= 0.0:
				y = platform["y"]
				vy = 0.0
				on_ground = true
	accept_ground(on_ground)

func accept_ground(on_ground: bool) -> void:
	if not grounded and on_ground: emit("dust")
	grounded = on_ground

func choose_state(input: Dictionary) -> void:
	if force_state != "none":
		state = force_state
	elif attacking_this_step:
		pass # El adaptador aplica el impacto antes de avanzar el reloj.
	elif is_dashing:
		set_state("dash")
	elif not grounded:
		if vy < 30.0: set_state("jump")
		elif state not in ["fall", "fall_loop"]: set_state("fall")
	elif absf(vx) > 30.0:
		set_state("run" if absf(vx) > walk_speed + 15.0 or input.get("is_running", false) else "walk")
	else:
		set_state("idle")

func active_hit() -> bool:
	if combo_hit_done or not attacking_this_step or force_state != "none": return false
	if state == "combo_1": return frame_index in [4, 5, 6]
	if state == "combo_2": return frame_index in [2, 3, 4, 5]
	if state == "combo_3": return frame_index in [2, 3, 4, 5, 6]
	return false

func sword_rect() -> Rect2:
	var reach := 70.0 if state == "combo_3" else (62.0 if state == "combo_2" else 55.0)
	var top := -45.0 if state == "combo_3" else (-50.0 if state == "combo_2" else -42.0)
	var height := 52.0 if state == "combo_3" else (48.0 if state == "combo_2" else 38.0)
	return Rect2(x if facing == 1 else x - reach, y + top, reach, height)

func damage() -> int:
	return {"combo_1": 25, "combo_2": 45, "combo_3": 60, "combo_1_end": 15}.get(state, 0)

func animate(dt: float) -> void:
	var fps: float = fps_overrides.get(state, FPS[state])
	var duration := 1.0 / maxf(1.0, fps)
	anim_timer += dt
	# El HTML avanza como máximo una celda por actualización (sin bucle while).
	if anim_timer < duration: return
	anim_timer -= duration
	if frame_index + 1 < FRAMES[state]:
		frame_index += 1
	elif force_state == state:
		frame_index = 0
	elif state == "combo_1":
		if combo3_buffered:
			combo3_buffered = false
			combo2_buffered = false
			set_state("combo_3")
			vx = facing * 180.0
			prompt("TERCER GOLPE DEMOLEDOR", 0.85)
			emit("slash", {"pitch": 0.85})
		elif combo2_buffered:
			combo2_buffered = false
			set_state("combo_2")
			vx = facing * 160.0
			prompt("COMBO 2 · CORTE ASCENDENTE", 0.75)
			emit("slash", {"pitch": 1.35})
		else: set_state("combo_1_end")
	elif state == "combo_2":
		if combo3_buffered or attack_buffered:
			combo3_buffered = false
			attack_buffered = false
			set_state("combo_3")
			vx = facing * 200.0
			prompt("COMBO 3 · REMATE DEMOLEDOR", 0.9)
			emit("slash", {"pitch": 0.8})
		else: set_state("combo_1_end")
	elif state == "combo_3": set_state("idle" if grounded else "fall")
	elif state == "combo_1_end": set_state("idle" if grounded else "fall")
	elif state == "fall": set_state("fall_loop")
	elif state in ["idle", "walk", "run", "fall_loop"]: frame_index = 0
