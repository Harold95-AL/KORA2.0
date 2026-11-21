extends Control
## Recurso SpriteFrames compartido con Player.tscn: cambios visibles en ambos.

const ANIMATIONS: Array[StringName] = [
	&"idle", &"walk", &"run", &"jump", &"fall", &"fall_loop",
	&"combo_1", &"combo_2", &"combo_3", &"combo_1_end"
]
@onready var sprite: AnimatedSprite2D = $Preview
@onready var info: Label = $Info
@onready var selector: OptionButton = $Animation

func _ready() -> void:
	GameManager.campaign_active = false
	for animation in ANIMATIONS:
		selector.add_item(String(animation))
	selector.item_selected.connect(_select_animation)
	$Replay.pressed.connect(_replay)
	$Back.pressed.connect(_go_back)
	$Zoom.item_selected.connect(_set_zoom)
	$Speed.value_changed.connect(_set_speed)
	_select_animation(0)
	preload("res://scripts/ui/display_layout.gd").apply(self)
	sprite.position *= 3.0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_set_zoom($Zoom.selected)

func _process(_delta: float) -> void:
	info.text = "%s   |   %d / %d fotogramas   |   %.0f FPS base\nCelda 128 × 128 · anclaje de pies (64, 80)" % [
		sprite.animation, sprite.frame + 1,
		sprite.sprite_frames.get_frame_count(sprite.animation),
		sprite.sprite_frames.get_animation_speed(sprite.animation)]

func _select_animation(index: int) -> void:
	sprite.stop()
	sprite.play(ANIMATIONS[index])

func _replay() -> void:
	_select_animation(selector.selected)

func _set_zoom(index: int) -> void:
	sprite.scale = Vector2.ONE * (index + 1) * 3.0

func _set_speed(value: float) -> void:
	sprite.speed_scale = value

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("gallery") or event.is_action_pressed("pause"):
		_go_back()

func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/lab/reference_lab.tscn")

