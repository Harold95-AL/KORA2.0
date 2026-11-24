extends Control

var landscape := Sprite2D.new()
var cursor := Label.new()
var sound := AudioStreamPlayer.new()
var elapsed := 0.0
var selected: Button

func _ready() -> void:
	GameManager.campaign_active = false
	$Title.text = "VOIDBOUND"
	$Background.add_child(landscape)
	landscape.texture = preload("res://assets/sprites/backgrounds/kora/level_1_1/ruinas_cristalinas.png")
	landscape.position = Vector2(320,180)
	landscape.scale = Vector2(0.41,0.41)
	landscape.modulate = Color(0.48,0.51,0.64)
	var options := Button.new()
	options.text = "Opciones"
	options.position = Vector2(334,248)
	options.size = Vector2(180,30)
	add_child(options)
	options.pressed.connect(GameUI.show_options)
	cursor.text = ">"
	cursor.add_theme_color_override("font_color", Color("86ffda"))
	add_child(cursor)
	add_child(sound)
	sound.stream = preload("res://assets/audio/player/jump.wav")
	sound.pitch_scale = 2.2
	sound.volume_db = -23
	for node in get_children():
		if node is Button:
			node.focus_entered.connect(func(): select_button(node))
			node.mouse_entered.connect(func(): if not node.disabled and not GameUI.overlay.visible: node.grab_focus())
	$NewGame.grab_focus()
	GameUI.clear_dialogues()
	$Version.text = "RETO EXIGENTE · Prólogo + 12 secciones + Epílogo"
	$Legend.text = "DOMINA EL DASH\nK: impulso\n1 dash aéreo por salto\nAmarillo: esquiva el ataque\nVerde: contraataca\nI: rompe la guardia\nF1: selector de secciones"
	$NewGame.pressed.connect(GameManager.new_game)
	$Continue.disabled = GameManager.section_index < 0
	$Continue.pressed.connect(func() -> void: GameManager.goto_section(GameManager.section_index))
	$Sections.pressed.connect(GameUI.show_selector)
	$Laboratory.pressed.connect(func() -> void: GameManager.change_scene("res://scenes/lab/reference_lab.tscn"))
	$Exit.pressed.connect(func() -> void: get_tree().quit())
	$Footer.text = "F11: pantalla completa · Progreso durante esta sesión · Sprites: Ozzbit Games"
	preload("res://scripts/ui/display_layout.gd").apply(self)


func select_button(button: Button) -> void:
	if selected != null and selected != button:
		sound.play()
	selected = button

func _process(delta: float) -> void:
	elapsed += delta
	landscape.position.x = 320 + roundf(sin(elapsed * 0.17) * 12)
	if is_instance_valid(selected):
		cursor.position = selected.position + Vector2(-12 + roundf(sin(elapsed * 5) * 2), 8)
