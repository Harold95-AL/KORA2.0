extends Node2D
## Escenario de trabajo, sin progreso narrativo ni combate con daño.

@onready var player: KoraPlayer = $Player
@onready var status: Label = $HUD/Status
@onready var pause_panel: PanelContainer = $HUD/PausePanel
var body_visible := false

func _ready() -> void:
	GameManager.campaign_active = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Los controles de laboratorio permanecen activos durante la pausa.
	$Player.process_mode = Node.PROCESS_MODE_PAUSABLE
	$HUD/Top/Buttons/Gallery.pressed.connect(_open_gallery)
	$HUD/Top/Buttons/Reset.pressed.connect(player.respawn)
	$HUD/Top/Buttons/Body.toggled.connect(_set_body)
	preload("res://scripts/ui/display_layout.gd").apply($HUD)

func _process(_delta: float) -> void:
	status.text = "%s  |  fotograma %d/%d  |  velocidad %.0f px/s" % [
		player.sprite.animation, player.sprite.frame + 1,
		player.sprite.sprite_frames.get_frame_count(player.sprite.animation), player.velocity.x]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("records"):
		get_tree().paused = false
		GameManager.menu()
		return
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		pause_panel.visible = get_tree().paused
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("gallery"):
		_open_gallery()
	elif event.is_action_pressed("debug_collision"):
		$HUD/Top/Buttons/Body.button_pressed = not body_visible

func _set_body(enabled: bool) -> void:
	body_visible = enabled
	player.set_debug_body(enabled)

func _open_gallery() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/lab/sprite_gallery.tscn")

func _draw() -> void:
	for x in range(0, 1281, 32):
		draw_line(Vector2(x, 0), Vector2(x, 360), Color("14253a"))
	for y in range(0, 361, 32):
		draw_line(Vector2(0, y), Vector2(1280, y), Color("14253a"))

