extends Area2D
@export var spike_sheet: Texture2D
@export var width: float = 56.0
@export var cycle: bool = true
@export var phase_offset: float = 0.0
@export var disabled_by: String = ""
@export var rest_time := 0.65
@export var warning_time := 0.45
@export var active_time := 1.8
@export var damage := 2
var time: float = 0.0
var phase: int = 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 23)
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = Vector2(width * 0.5, -11.5)

func _physics_process(delta: float) -> void:
	time += delta
	var t := fmod(time + phase_offset, rest_time + warning_time + active_time)
	phase = 0 if t < rest_time else (1 if t < rest_time + warning_time else 2)
	if not cycle:
		phase = 2
	if not disabled_by.is_empty() and GameManager.has_key(disabled_by):
		phase = 0
	if phase == 2:
		for body in get_overlapping_bodies():
			if body is KoraPlayer:
				body.take_damage(damage, global_position + Vector2(width * 0.5, 0))
	queue_redraw()

func _draw() -> void:
	if spike_sheet:
		# La silueta ocupa las filas 56 a 203 de la hoja original.
		var visible_height: int = [4, 11, 23][phase]
		var source_height := roundi(148.0 * visible_height / 23.0)
		var source := Rect2(0, 56, 256, source_height)
		var tint: Color = [Color("72718e"), Color.WHITE, Color.WHITE][phase]
		var count := maxi(1, roundi(width / 40.0))
		for index in count:
			var left := roundf(index * width / count)
			var right := roundf((index + 1) * width / count)
			draw_texture_rect_region(spike_sheet, Rect2(left, -visible_height, right - left, visible_height), source, tint)
		if phase == 1:
			draw_rect(Rect2(0, -2, width, 2), Color("ffc96b"))
		return
	var color: Color = [Color("314659"), Color("ffc96b"), Color("ff646e")][phase]
	draw_rect(Rect2(0, -4, width, 4), color)
	for x in range(0, int(width), 14):
		draw_colored_polygon(PackedVector2Array([Vector2(x, -4), Vector2(x + 7, -22 if phase == 2 else -10), Vector2(x + 14, -4)]), color)

