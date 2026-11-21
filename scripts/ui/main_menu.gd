extends Control

func _ready() -> void:
	GameManager.campaign_active = false
	GameUI.clear_dialogues()
	$Version.text = "RETO EXIGENTE · Prólogo + 12 secciones + Epílogo"
	$Legend.text = "DOMINA EL DASH\nK / E / X: impulso\n1 dash aéreo por salto\nAmarillo: esquiva el ataque\nVerde: contraataca\nI: rompe la guardia\nF1: selector de secciones"
	$NewGame.pressed.connect(GameManager.new_game)
	$Continue.disabled = GameManager.section_index < 0
	$Continue.pressed.connect(func() -> void: GameManager.goto_section(GameManager.section_index))
	$Sections.pressed.connect(GameUI.show_selector)
	$Laboratory.pressed.connect(func() -> void: GameManager.change_scene("res://scenes/lab/reference_lab.tscn"))
	$Exit.pressed.connect(func() -> void: get_tree().quit())
	$Footer.text = "F11: pantalla completa · Progreso durante esta sesión · Sprites: Ozzbit Games"
	preload("res://scripts/ui/display_layout.gd").apply(self)

