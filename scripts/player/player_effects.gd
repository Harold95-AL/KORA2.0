extends Node2D
## Estelas, polvo, impactos y vibración con los parámetros del HTML.
var particles: Array[Dictionary] = []
var ghosts: Array[Dictionary] = []
var numbers: Array[Dictionary] = []
var sounds: Dictionary = {}

func handle_event(event: Dictionary, player: Node2D) -> void:
	var pos: Vector2 = event.position
	match event.type:
		"dust":
			for i in range(5):
				particle(pos + Vector2(randf_range(-8,8),0), Vector2(randf_range(-20,20),-randf()*25), 0.35, randf_range(1.5,4), ["38bdf8","c084fc","818cf8","e2e8f0"].pick_random())
		"ghost", "dash_tick":
			if event.type == "ghost" or randf() < 0.75:
				ghosts.append({"position": pos, "facing": event.facing, "texture": player.sprite.sprite_frames.get_frame_texture(event.state,event.frame), "alpha": 0.75})
		"rumble":
			var pads := Input.get_connected_joypads()
			if not pads.is_empty(): Input.start_joy_vibration(pads[0],event.weak,event.strong,event.duration)
		"slash": play_sound("slash_%d" % roundi(event.pitch * 100))
		"dash", "jump": play_sound(event.type)
		"shake": player.camera_shake(event.duration,event.intensity)

func particle(pos: Vector2, velocity: Vector2, life: float, size: float, color: String) -> void:
	particles.append({"position":pos,"velocity":velocity,"life":life,"size":size,"color":Color(color)})

func impact(pos: Vector2, heavy: bool, damage: int, player: Node2D) -> void:
	for i in range(14):
		var angle := randf()*TAU
		particle(pos+Vector2(0,-25),Vector2(cos(angle),sin(angle))*randf_range(70,220),0.3,randf_range(2,5),["00f0ff","c084fc","fef08a","38bdf8","ffffff"].pick_random())
	numbers.append({"position":pos+Vector2(randf_range(-10,10),-45),"text":str(damage),"alpha":1.0})
	play_sound("slam" if heavy else "hit")
	var pads := Input.get_connected_joypads()
	if not pads.is_empty(): Input.start_joy_vibration(pads[0],0.7 if heavy else 0.4,1.0 if heavy else 0.8,0.12 if heavy else 0.08)
	if heavy:
		player.camera_shake(0.28,7)
		for i in range(12):
			particle(pos+Vector2(randf_range(-8,8),-4),Vector2(randf_range(-110,110),-randf()*200-40),0.45,randf_range(2,5),["f59e0b","00f0ff"].pick_random())

func play_sound(key: String) -> void:
	if not sounds.has(key):
		sounds[key] = load("res://assets/audio/player/" + key + ".wav")
	if sounds[key] == null: return
	# El servidor de audio no mezcla voces durante las pruebas sin ventana.
	if DisplayServer.get_name() == "headless": return
	var audio := AudioStreamPlayer.new()
	audio.stream = sounds[key]
	add_child(audio)
	audio.finished.connect(audio.queue_free)
	audio.play()

func _physics_process(delta: float) -> void:
	for i in range(particles.size()-1,-1,-1):
		particles[i].position += particles[i].velocity * delta
		particles[i].life -= delta
		if particles[i].life <= 0.0: particles.remove_at(i)
	for i in range(ghosts.size()-1,-1,-1):
		ghosts[i].alpha -= 3.5*delta
		if ghosts[i].alpha <= 0.0: ghosts.remove_at(i)
	for i in range(numbers.size()-1,-1,-1):
		numbers[i].position.y -= 80.0*delta
		numbers[i].alpha -= 1.5*delta
		if numbers[i].alpha <= 0.0: numbers.remove_at(i)
	queue_redraw()

func _draw() -> void:
	for ghost in ghosts:
		draw_set_transform(ghost.position.round(),0,Vector2(ghost.facing,1))
		draw_texture_rect(ghost.texture,Rect2(-64,-80,128,128),false,Color(1,1,1,maxf(0,ghost.alpha*0.6)))
	draw_set_transform(Vector2.ZERO)
	for p in particles:
		draw_rect(Rect2(p.position.round(),Vector2.ONE*p.size),p.color)
	for number in numbers:
		draw_string(ThemeDB.fallback_font,number.position,"-"+number.text,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color(1,0.75,0.14,number.alpha))
