extends Node2D
const PULSE = preload("res://scripts/entities/projectile.gd")
@export var display_name := "ORÚ"
@export var max_health: int = 300
@export var arena_left: float = 3000.0
@export var arena_right: float = 3720.0
@export var state_key := "boss"
@export var victory_story := "STORY_08"
@export var intro_story := "ORU_INTRO"
@export var saren := false
var health: int
var phase: int = 1
var active := false
var mode := "waiting"
var timer: float = 0.0
var move_index: int = 0
var target := Vector2.ZERO
var flash: float = 0.0
var chained_attacks := 0
var echo_fired := false
var player: KoraPlayer

func _ready() -> void:
	health = max_health
	if GameManager.has_key(state_key):
		mode = "defeated"
		health = 0
	else:
		add_to_group("enemies")

func _physics_process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("player") as KoraPlayer
	if not is_instance_valid(player) or mode == "defeated":
		queue_redraw()
		return
	flash = maxf(0.0, flash - delta)
	if not active:
		if player.global_position.x > arena_left + 42.0 and player.global_position.x < arena_right - 20.0:
			active = true
			get_tree().current_scene.set_meta("arena_active", true)
			add_to_group("active_boss")
			NarrativeManager.trigger(intro_story)
			mode = "rest"
			timer = 1.0
		return
	phase = 2 if health <= max_health / 2 else 1
	if phase == 2 and saren:
		for platform in get_tree().get_nodes_in_group("arena_platforms"):
			platform.unstable = true
	timer -= delta
	if timer <= 0.0:
		match mode:
			"rest":
				chained_attacks = 0
				_warn()
			"warning":
				_fire()
				mode = "attack"
				timer = 0.42
				echo_fired = false
			"attack":
				move_index = (move_index + 1) % (4 if saren else 3)
				if phase == 2 and chained_attacks == 0:
					chained_attacks += 1
					_warn()
				else:
					mode = "rest"
					timer = 0.95 if phase == 1 else 0.70
	if mode == "attack" and move_index == 1 and phase == 2 and timer < 0.20 and not echo_fired:
		echo_fired = true
		_fire()
	queue_redraw()

func _warn() -> void:
	mode = "warning"
	timer = 0.65 if phase == 1 else 0.50
	if move_index == 2: timer = 0.50
	target = player.global_position

func _fire() -> void:
	match move_index:
		0:
			if absf(player.global_position.x - global_position.x) < 150.0 and absf(player.global_position.y - global_position.y) < 70.0:
				player.take_damage(2, global_position)
		1:
			for direction in [-1, 1]:
				_spawn(Vector2(direction * (265.0 if phase == 1 else 320.0), 0), Vector2(0, -12), true)
		2:
			# Marca fijada al comenzar el aviso: correr desde el centro no basta.
			if absf(player.global_position.x-target.x)<112.0 and absf(player.global_position.y-target.y)<90.0:
				player.take_damage(2,target)
		3:
			var direction := (target+Vector2(0,-22)-global_position-Vector2(0,-50)).normalized()
			for angle in [-0.22,0.0,0.22]:
				_spawn(direction.rotated(angle)*(280.0 if phase==1 else 340.0),Vector2(0,-50),false)

func _spawn(velocity: Vector2, offset: Vector2, ground: bool) -> void:
	var projectile := Node2D.new()
	projectile.set_script(PULSE)
	projectile.velocity = velocity
	projectile.ground_wave = ground
	projectile.position = global_position + offset
	get_tree().current_scene.add_child(projectile)

func take_hit(amount: int) -> void:
	if not active or mode != "rest":
		return
	health = maxi(0, health - amount)
	flash = 0.12
	if health == 0:
		mode = "defeated"
		active = false
		GameManager.set_key(state_key)
		remove_from_group("active_boss")
		remove_from_group("enemies")
		get_tree().current_scene.set_meta("arena_active", false)
		# El final del combate limpia proyectiles antes de la conversación.
		for child in get_tree().current_scene.get_children():
			if child.get_script() == PULSE:
				child.queue_free()
		NarrativeManager.trigger(victory_story)
	queue_redraw()

func state_label() -> String:
	if mode == "rest":
		return "VULNERABLE · %.1f s" % maxf(timer,0.0)
	if mode == "warning":
		return ["DASH FUERA DEL ARCO", "SALTA · ONDAS", "DASH FUERA DE LA MARCA", "SALTO + DASH · ABANICO"][move_index]
	return "ESCUDO"

func hurt_rect() -> Rect2:
	var height := 90.0 if saren else 68.0
	return Rect2(global_position + Vector2(-38,-height),Vector2(76,height))

func _draw() -> void:
	var color := Color("79d9d3") if mode == "rest" else Color("998ce3")
	if mode == "defeated":
		color = Color("556b87")
	if mode == "warning":
		color = Color("ffc76a")
	if flash > 0.0:
		color = Color.WHITE
	var height := 90.0 if saren else 68.0
	draw_colored_polygon(PackedVector2Array([Vector2(-30, 0), Vector2(-38, -height * 0.6), Vector2(0, -height), Vector2(38, -height * 0.6), Vector2(30, 0)]), color)
	draw_circle(Vector2(0, -height * 0.55), 12, Color("1d2e45"))
	draw_circle(Vector2(0, -height * 0.55), 5, Color("e7f7ff"))
	if mode == "warning" or mode == "attack":
		if move_index == 0:
			draw_arc(Vector2(0, -15), 150, PI, TAU, 32, Color("ffc76a"), 3)
		elif move_index == 1:
			draw_line(Vector2(-95, -6), Vector2(95, -6), Color("ff8792"), 4)
		elif move_index == 2:
			var mark_color := Color(1,0.75,0.25,0.24) if mode=="warning" else Color(1,0.25,0.35,0.65)
			draw_rect(Rect2(target-global_position+Vector2(-112,-90),Vector2(224,100)),mark_color)
			draw_line(target-global_position+Vector2(-112,0),target-global_position+Vector2(112,0),Color("ffc76a"),3)
		else:
			var direction := (target-global_position+Vector2(0,28)).normalized()
			for angle in [-0.22,0.0,0.22]:
				draw_line(Vector2(0,-50),Vector2(0,-50)+direction.rotated(angle)*220,Color("ffc76a"),1.5)

