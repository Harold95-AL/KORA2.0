extends SceneTree
## Escenarios con el jugador y temporizadores reales; comprueba daño y esquiva.
var failures := 0
var gm: Node
var arena: Node2D
var player: Node2D

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	if ok: print("OK RETO: ",label)
	else:
		failures += 1
		push_error(label)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func reset_player() -> void:
	for action in ["move_left","move_right","jump","dash","attack","heavy_attack"]: Input.action_release(action)
	player.position = Vector2(1000,320)
	player.velocity = Vector2.ZERO
	player.motion = load("res://scripts/player/lab_motion.gd").new()
	player.previous_keys.clear()
	player.invulnerability = 0
	player.air_dash_spent = false
	gm.health = 6
	await frames(4)

func enemy(style: String) -> Node2D:
	var actor = load("res://scenes/entities/BaseEnemy.tscn").instantiate()
	actor.position = Vector2(1045,320)
	actor.attack_style = style
	actor.max_health = 150
	arena.add_child(actor)
	return actor

func run() -> void:
	gm = root.get_node("GameManager")
	gm.campaign_active = true
	gm.section_index = 0
	arena = Node2D.new()
	root.add_child(arena)
	current_scene = arena
	var floor_body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(5000,80)
	shape.shape = rect
	floor_body.position = Vector2(1200,360)
	floor_body.add_child(shape)
	arena.add_child(floor_body)
	player = load("res://scenes/player/player.tscn").instantiate()
	player.position = Vector2(1000,320)
	arena.add_child(player)
	await reset_player()
	var attacker = enemy("duelist")
	await frames(15)
	check(attacker.mode=="warning" and gm.health==6,"El aviso precede al daño")
	await frames(28)
	check(gm.health==4,"Permanecer en el ataque quita dos puntos")
	check(player.invulnerability <= 0.55,"Recuperación tras daño limitada a 0,55 s")
	await frames(9)
	check(attacker.mode=="rest","La embestida deja una apertura real")
	attacker.free()
	await reset_player()
	attacker = enemy("duelist")
	await frames(5)
	Input.action_press("move_left")
	await frames(1)
	Input.action_press("dash")
	await frames(1)
	Input.action_release("dash")
	await frames(38)
	check(gm.health==6 and player.position.x<850,"El dash evita la embestida sin inmunidad")
	attacker.free()
	await reset_player()
	attacker = enemy("brute")
	attacker.set_physics_process(false)
	attacker.direction = -1
	attacker.mode = "warning"
	attacker.take_hit(25)
	check(attacker.health==144,"La guardia frontal reduce un golpe ligero")
	attacker.take_hit(60)
	check(attacker.health==84 and attacker.mode=="rest","El fuerte rompe la guardia y abre contraataque")
	attacker.mode = "warning"
	player.position.x = 1090
	attacker.take_hit(25)
	check(attacker.health==59,"Flanquear evita la guardia")
	attacker.free()
	await reset_player()
	attacker = enemy("ranged")
	attacker.position.x = 1180
	await frames(12)
	var locked_aim: Vector2 = attacker.aim
	Input.action_press("jump")
	await frames(15)
	check(attacker.aim==locked_aim,"El tirador fija la puntería durante el aviso")
	await frames(35)
	check(gm.health==6,"Saltar evade el disparo anunciado")
	attacker.free()
	for node in arena.get_children():
		if node.get_script()==load("res://scripts/entities/projectile.gd"): node.queue_free()
	await reset_player()
	var boss = load("res://scenes/entities/Boss.tscn").instantiate()
	boss.position = Vector2(1220,320)
	boss.arena_left = 500.0
	boss.arena_right = 1700.0
	boss.intro_story = ""
	arena.add_child(boss)
	boss.active = true
	boss.mode = "rest"
	boss.timer = 10.0
	boss.player = player
	boss.move_index = 2
	boss._warn()
	Input.action_press("move_left")
	await frames(34)
	check(gm.health==4,"Correr desde el centro no basta para la marca del jefe")
	boss.set_physics_process(false)
	await reset_player()
	boss.player = player
	boss.move_index = 2
	boss._warn()
	boss.set_physics_process(true)
	Input.action_press("move_left")
	await frames(2)
	Input.action_press("dash")
	await frames(1)
	Input.action_release("dash")
	await frames(31)
	check(gm.health==6,"Dash fuera de la marca evita el golpe del jefe")
	boss.set_physics_process(false)
	await reset_player()
	player.invulnerability = 99
	boss.health = boss.max_health/2
	boss.mode = "rest"
	boss.timer = 0.01
	boss.move_index = 0
	boss.set_physics_process(true)
	await frames(64)
	check(boss.phase==2 and boss.chained_attacks==1 and boss.mode!="rest","La segunda fase encadena ataques antes de abrirse")
	await frames(60)
	check(boss.mode=="rest" and boss.timer<=0.70,"Recuperación de segunda fase de hasta 0,70 s")
	boss.free()
	await reset_player()
	player.position = Vector2(1000,-500)
	player.motion.grounded = false
	Input.action_press("dash")
	await frames(1)
	Input.action_release("dash")
	await frames(28)
	check(player.air_dash_spent,"El primer dash aéreo consume la carga")
	Input.action_press("dash")
	await frames(2)
	Input.action_release("dash")
	check(not player.motion.is_dashing,"No se puede volar encadenando dashes en campaña")
	await frames(100)
	check(player.motion.grounded and not player.air_dash_spent,"Aterrizar recupera el dash aéreo")
	await reset_player()
	var ledge = load("res://scenes/entities/MovingPlatform.tscn").instantiate()
	ledge.position = Vector2(970,240)
	ledge.width = 64.0
	ledge.unstable = true
	ledge.collapse_delay = 0.30
	arena.add_child(ledge)
	player.position = Vector2(1000,239.8)
	player.velocity = Vector2.ZERO
	await frames(10)
	check(ledge.visible and player.is_on_floor(),"La repisa breve permite apoyar y preparar el siguiente salto")
	await frames(17)
	check(not ledge.visible and player.position.y>242,"Esperar demasiado derrumba la repisa")
	await frames(135)
	check(ledge.visible,"La repisa reaparece para reintentar")
	ledge.free()
	print("COMBATE EXIGENTE: ",failures," fallos")
	gm.campaign_active = false
	quit(0 if failures==0 else 1)
