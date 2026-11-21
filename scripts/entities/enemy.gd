extends CharacterBody2D
## Dirección fijada durante el aviso: esquivar deja una apertura para atacar.
const PULSE = preload("res://scripts/entities/projectile.gd")
@export var max_health := 110
@export var patrol_distance := 55.0
@export var speed := 80.0
@export_enum("duelist", "brute", "ranged") var attack_style := "duelist"
@export var combo_strikes := 1
var health: int
var origin_x: float
var direction := -1.0
var mode := "patrol"
var timer := 0.0
var flash := 0.0
var strike := 0
var hit_done := false
var aim := Vector2.ZERO
var player: KoraPlayer

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	origin_x = position.x

func _physics_process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("player") as KoraPlayer
	if not is_instance_valid(player) or health <= 0: return
	flash = maxf(0.0,flash-delta)
	velocity.y += 950.0*delta
	var difference := player.global_position-global_position
	velocity.x = 0.0
	match mode:
		"patrol":
			var reach := 340.0 if attack_style == "ranged" else 165.0
			if absf(difference.x) < reach and absf(difference.y) < 65.0 and _can_see_player():
				strike = 0
				_warn()
			else:
				if absf(position.x-origin_x) > patrol_distance or is_on_wall():
					direction = -1.0 if position.x>origin_x else 1.0
				if not _floor_ahead(): direction *= -1.0
				velocity.x = direction*speed
		"warning":
			timer -= delta
			if timer <= 0.0: _attack()
		"attack":
			timer -= delta
			if attack_style != "ranged":
				if _floor_ahead(): velocity.x = direction*(310.0 if attack_style=="brute" else 380.0)
				var reach := 68.0 if attack_style=="brute" else 48.0
				if not hit_done and difference.x*direction >= -12.0 and difference.x*direction < reach and absf(difference.y)<42.0:
					player.take_damage(3 if attack_style=="brute" else 2,global_position)
					hit_done = true
			if timer <= 0.0:
				strike += 1
				if strike < combo_strikes and absf(difference.x)<220 and absf(difference.y)<65:
					_warn(true)
				else:
					mode = "rest"
					timer = 0.8 if attack_style=="brute" else 0.65
		"rest":
			timer -= delta
			if timer <= 0.0: mode = "patrol"
	move_and_slide()
	queue_redraw()

func _floor_ahead() -> bool:
	if not is_on_floor(): return true
	var query := PhysicsRayQueryParameters2D.create(global_position+Vector2(direction*26,-4),global_position+Vector2(direction*26,30),1)
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _can_see_player() -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position+Vector2(0,-22),player.global_position+Vector2(0,-22),1)
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _warn(chained := false) -> void:
	mode = "warning"
	direction = 1.0 if player.global_position.x>=global_position.x else -1.0
	aim = player.global_position+Vector2(0,-20)
	timer = 0.38 if chained else (0.66 if attack_style=="brute" else 0.55)
	hit_done = false

func _attack() -> void:
	mode = "attack"
	timer = 0.22
	if attack_style == "ranged":
		var shot := Node2D.new()
		shot.set_script(PULSE)
		shot.position = global_position+Vector2(0,-24)
		shot.velocity = (aim-shot.position).normalized()*300.0
		shot.damage = 2
		get_tree().current_scene.add_child(shot)

func take_hit(amount: int) -> void:
	if health <= 0: return
	var attacker := get_tree().get_first_node_in_group("player") as KoraPlayer
	var guarded := attack_style=="brute" and mode!="rest" and is_instance_valid(attacker) and (attacker.global_position.x-global_position.x)*direction>0
	if guarded and amount<60: amount = maxi(1,amount/4)
	elif guarded:
		mode = "rest"
		timer = 0.85
	health = maxi(0,health-amount)
	flash = 0.12
	if health==0:
		remove_from_group("enemies")
		queue_free()

func hurt_rect() -> Rect2:
	return Rect2(global_position+Vector2(-17,-32),Vector2(34,32))

func _draw() -> void:
	var color := Color("bd90ff") if attack_style=="ranged" else Color("f19474")
	if attack_style=="brute": color = Color("91a8ca")
	if mode=="rest": color = Color("79eda0")
	if mode=="warning" or mode=="attack":
		color = Color("ffd066") if mode=="warning" else Color("ff646e")
		if attack_style=="ranged":
			draw_line(Vector2(0,-24),aim-global_position,color,1.5)
		else:
			draw_rect(Rect2(0 if direction>0 else -145,-36,145,36),Color(color,0.18))
			draw_line(Vector2.ZERO,Vector2(direction*145,0),color,2)
	if flash>0: color = Color.WHITE
	draw_colored_polygon(PackedVector2Array([Vector2(-19,0),Vector2(-16,-27),Vector2(0,-38),Vector2(19,-22),Vector2(19,0)]),color)
	draw_circle(Vector2(8*direction,-23),3,Color("182438"))
	if attack_style=="brute" and mode!="rest": draw_line(Vector2(direction*21,-32),Vector2(direction*21,-3),Color("e1eafa"),4)
	draw_line(Vector2(-18,-43),Vector2(-18+36.0*health/max_health,-43),Color("f4c2a3"),3)
