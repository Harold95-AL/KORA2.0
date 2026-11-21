extends Control
@export var epilogue := false
var pages: Array = []
var index := 0
var elapsed: float = 0.0

func _ready() -> void:
	GameManager.campaign_active = false
	pages = NarrativeManager.content["EPILOGUE" if epilogue else "PROLOGUE"]["pages"]
	$Next.pressed.connect(_next)
	$Skip.pressed.connect(_finish)
	$Skip.text = "Ir a créditos" if epilogue else "Omitir prólogo"
	_show()
	preload("res://scripts/ui/display_layout.gd").apply(self)

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _show() -> void:
	$Heading.text = pages[index]["title"]
	$Text.text = pages[index]["text"]
	$Next.text = "Volver al menú" if epilogue and index == pages.size() - 1 else "Continuar · F / Enter"
	$Counter.text = "%d / %d" % [index + 1, pages.size()]
	if epilogue and index >= 3:
		NarrativeManager.flags["STORY_20"] = true

func _next() -> void:
	if index + 1 >= pages.size():
		if epilogue:
			GameManager.menu()
		else:
			_finish()
	else:
		index += 1
		_show()

func _finish() -> void:
	if epilogue:
		index = pages.size() - 1
		NarrativeManager.flags["STORY_20"] = true
		_show()
	else:
		NarrativeManager.flags["STORY_01"] = true
		GameManager.goto_section(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_next()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause"):
		_finish()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO,0,Vector2(3,3))
	draw_rect(Rect2(0, 0, 640, 360), Color("080f1c"))
	for star in range(60):
		var pos := Vector2(fmod(star * 137.0, 640.0), fmod(star * 71.0, 170.0))
		draw_circle(pos, 1, Color("45647e"))
	var t := fmod(elapsed, 4.0)
	var illuminated := t < 0.18 or (t > 0.7 and t < 1.3) or (t > 1.9 and t < 2.08)
	var color := Color("8de9d9") if illuminated else Color("233f56")
	for pulse in range(3):
		draw_rect(Rect2(256 + pulse * 48, 103, 30 if pulse == 1 else 10, 8), color)
	draw_arc(Vector2(320, 108), 65, 0, TAU, 64, Color("274e63"), 2)
