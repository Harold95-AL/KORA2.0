class_name KoraPlayer
extends CharacterBody2D
## Adaptador Godot del controlador HTML. La lógica vive en lab_motion.gd.
const Motion = preload("res://scripts/player/lab_motion.gd")
const Effects = preload("res://scripts/player/player_effects.gd")
@export var move_speed := 210.0
@export var walk_speed := 110.0
@export var jump_force := 380.0
@export var gravity := 950.0
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.12
@export var respawn_y := 600.0
@export var reference_collisions := false
@export var reference_platforms: Array[Dictionary] = []
@export var visual_scale := 2.0
@export var camera_target_offset := Vector2(0.0, -40.0)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var motion = Motion.new()
var effects: Node2D
var spawn_position := Vector2.ZERO
var invulnerability := 0.0
var show_body := false
var show_sprite_box := false
var previous_keys: Dictionary = {}
var previous_pad: Dictionary = {}
var mouse_attack := false
var mouse_heavy := false
var camera_position := Vector2.ZERO
var camera_initialized := false
var shake_time := 0.0
var shake_intensity := 0.0
var air_dash_spent := false

func _ready() -> void:
	spawn_position = global_position
	motion.x = global_position.x
	motion.y = global_position.y
	sprite.stop()
	effects = Node2D.new()
	effects.set_script(Effects)
	add_child(effects)
	effects.top_level = true
	effects.global_position = Vector2.ZERO
	effects.z_index = 2
	_sync_sprite()

func _physics_process(delta: float) -> void:
	if GameManager.campaign_active and GameManager.transitioning: return
	if Input.is_action_just_pressed("restart") or (not reference_collisions and global_position.y > respawn_y):
		respawn()
		return
	step_motion(minf(delta, 0.1), poll_input())

func poll_input() -> Dictionary:
	var input := {"move_x": 0.0, "is_running": false, "jump_pressed": false, "jump_held": false, "attack_pressed": false, "heavy_pressed": false, "dash_pressed": false}
	var pads := Input.get_connected_joypads()
	if not pads.is_empty():
		var pad := pads[0]
		var axis := Input.get_joy_axis(pad, JOY_AXIS_LEFT_X)
		if absf(axis) < 0.15: axis = 0.0
		if Input.is_joy_button_pressed(pad, JOY_BUTTON_DPAD_LEFT): axis = -1.0
		if Input.is_joy_button_pressed(pad, JOY_BUTTON_DPAD_RIGHT): axis = 1.0
		input.move_x = axis
		var buttons := {
			"jump": Input.is_joy_button_pressed(pad, JOY_BUTTON_A),
			"attack": Input.is_joy_button_pressed(pad, JOY_BUTTON_X),
			"heavy": Input.is_joy_button_pressed(pad, JOY_BUTTON_Y),
			"dash": Input.is_joy_button_pressed(pad, JOY_BUTTON_B) or Input.is_joy_button_pressed(pad, JOY_BUTTON_RIGHT_SHOULDER) or Input.get_joy_axis(pad, JOY_AXIS_TRIGGER_RIGHT) > 0.5}
		for key in buttons:
			input[key + "_pressed"] = buttons[key] and not previous_pad.get(key, false)
		input.jump_held = buttons.jump
		input.is_running = Input.is_joy_button_pressed(pad, JOY_BUTTON_LEFT_SHOULDER)
		previous_pad = buttons
	if Input.is_action_pressed("move_left"): input.move_x = -1.0
	if Input.is_action_pressed("move_right"): input.move_x = 1.0
	input.is_running = input.is_running or Input.is_action_pressed("run")
	var keys := {"jump": Input.is_action_pressed("jump"), "attack": Input.is_action_pressed("attack") or mouse_attack, "heavy": Input.is_action_pressed("heavy_attack") or mouse_heavy, "dash": Input.is_action_pressed("dash")}
	for key in keys:
		input[key + "_pressed"] = input[key + "_pressed"] or (keys[key] and not previous_keys.get(key, false))
	input.jump_held = input.jump_held or keys.jump
	previous_keys = keys
	mouse_attack = false
	mouse_heavy = false
	return input

func step_motion(delta: float, input: Dictionary) -> void:
	invulnerability = maxf(0.0, invulnerability - delta)
	motion.walk_speed = walk_speed
	motion.run_speed = move_speed
	motion.jump_force = jump_force
	motion.gravity = gravity
	motion.coyote_max = coyote_time
	motion.buffer_max = jump_buffer_time
	# El HTML usa doubles: no realimentar el redondeo float32 de Vector2.
	# Sí admitir teletransportes y cambios de velocidad externos.
	if not reference_collisions or global_position != Vector2(motion.x, motion.y):
		motion.x = global_position.x
		motion.y = global_position.y
	if not reference_collisions or velocity != Vector2(motion.vx, motion.vy):
		motion.vx = velocity.x
		motion.vy = velocity.y
	# En campaña, un dash aéreo por salto impide sobrevolar toda la ruta.
	# La pista HTML conserva sus reglas originales.
	var command := input.duplicate()
	var campaign_rules := GameManager.campaign_active and not reference_collisions
	if campaign_rules and not motion.grounded and air_dash_spent:
		command["dash_pressed"] = false
	var was_dashing: bool = motion.is_dashing
	var was_grounded: bool = motion.grounded
	motion.before_move(delta, command)
	if campaign_rules and not was_grounded and not was_dashing and motion.is_dashing:
		air_dash_spent = true
	if reference_collisions:
		motion.integrate_reference(delta, reference_platforms)
		global_position = Vector2(motion.x, motion.y)
	else:
		velocity = Vector2(motion.vx, motion.vy)
		move_and_slide()
		motion.x = global_position.x
		motion.y = global_position.y
		motion.vx = velocity.x
		motion.vy = velocity.y
		var on_ground := is_on_floor()
		if not on_ground and motion.vy >= 0.0:
			on_ground = test_move(global_transform, Vector2(0, 0.1))
		motion.accept_ground(on_ground)
	if motion.grounded: air_dash_spent = false
	motion.choose_state(input)
	_update_attack()
	motion.animate(delta)
	velocity = Vector2(motion.vx, motion.vy)
	_sync_sprite()
	for event in motion.events:
		effects.handle_event(event, self)
	motion.events.clear()
	_update_camera()
	queue_redraw()

func _sync_sprite() -> void:
	sprite.animation = motion.state
	sprite.frame = motion.frame_index
	sprite.flip_h = motion.facing < 0
	sprite.modulate.a = 0.45 if invulnerability > 0.0 and fmod(invulnerability, 0.16) < 0.08 else 1.0

func _update_camera() -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera == null: return
	camera.top_level = true
	# Mismo campo visible al reducir la ventana; Full HD nativo, sin saltos
	# de zoom causados por el escalado entero anterior.
	camera.zoom = Vector2.ONE * visual_scale * 0.5
	var target := global_position + camera_target_offset
	if GameManager.campaign_active and not reference_collisions:
		# Mostrar el aterrizaje de los huecos de 230 px antes de saltar.
		target.x += 70.0 * motion.facing
	# La sección vertical conserva visión del próximo descanso y sus límites.
	if GameManager.campaign_active and GameManager.section_index == 8:
		target.y += 75.0
	if not camera_initialized:
		camera_position = target
		camera_initialized = true
	camera_position += (target - camera_position) * 0.12
	if shake_time > 0.0:
		shake_time -= 0.016
		camera_position += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_intensity
	camera.global_position = camera_position.round()

func camera_shake(duration: float, intensity: float) -> void:
	shake_time = duration
	shake_intensity = intensity

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT: mouse_attack = true
		if event.button_index == MOUSE_BUTTON_RIGHT: mouse_heavy = true
	if GameManager.campaign_active and event.is_action_pressed("interact"):
		GameUI.interact_nearest()
		get_viewport().set_input_as_handled()

func _update_attack() -> void:
	if not motion.active_hit(): return
	if not reference_collisions:
		motion.x = global_position.x
		motion.y = global_position.y
	var sword: Rect2 = motion.sword_rect()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var target := Rect2(enemy.global_position + Vector2(-19, -38), Vector2(38, 38))
		if enemy.has_method("hurt_rect"): target = enemy.hurt_rect()
		if not sword.intersects(target): continue
		if enemy.has_method("receive_lab_hit"):
			enemy.receive_lab_hit(motion.damage(), motion.facing)
		else:
			enemy.take_hit(motion.damage())
		motion.combo_hit_done = true
		effects.impact(enemy.global_position, motion.state == "combo_3", motion.damage(), self)
		break # Una colisión por golpe, como el saco del HTML.

func is_attacking() -> bool:
	return motion.is_attacking()

func force_combo(state: String) -> void:
	motion.force_combo(state)
	velocity = Vector2(motion.vx, motion.vy)

func force_dash() -> void:
	motion.dash()
	velocity = Vector2(motion.vx, motion.vy)

func take_damage(amount: int, _source: Vector2) -> void:
	if not GameManager.campaign_active or invulnerability > 0.0 or GameManager.transitioning: return
	invulnerability = 0.55
	camera_shake(0.12, 3.0)
	GameManager.damage(amount)

func respawn() -> void:
	if GameManager.campaign_active:
		GameManager.respawn()
		return
	global_position = spawn_position
	velocity = Vector2.ZERO
	if reference_collisions:
		# Reset del HTML: conserva el estado, los búferes y los temporizadores.
		motion.x = spawn_position.x
		motion.y = spawn_position.y
		motion.vx = 0.0
		motion.vy = 0.0
		return
	motion = Motion.new()
	motion.x = global_position.x
	motion.y = global_position.y
	previous_keys.clear()
	previous_pad.clear()
	mouse_attack = false
	mouse_heavy = false
	invulnerability = 0.0
	air_dash_spent = false
	_sync_sprite()
	camera_initialized = false

func set_debug_body(enabled: bool) -> void:
	show_body = enabled
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.3125))
	draw_circle(Vector2.ZERO, 16, Color(0, 0, 0, 0.4))
	draw_set_transform(Vector2.ZERO, 0, Vector2(motion.facing, 1))
	if motion.is_dashing:
		for i in range(4):
			draw_line(Vector2(-25,-32+i*8),Vector2(-45-randf()*20,-32+i*8),Color("00f0ff"),1.5)
	draw_set_transform(Vector2.ZERO)
	if show_body:
		draw_rect(Rect2(-13,-38,26,38),Color("22c55e"),false,1.5)
		if is_attacking():
			var rect: Rect2 = motion.sword_rect()
			rect.position -= global_position
			draw_rect(rect,Color(1,0.3,0.3,0.35))
			draw_rect(rect,Color("ef4444"),false)
	if show_sprite_box: draw_rect(Rect2(-64,-80,128,128),Color(1,1,0,0.4),false)
