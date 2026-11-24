extends PanelContainer
## Texto del escenario en una placa de pantalla, alineada al píxel y con líneas cortas.
const PLATE_STYLE := preload("res://resources/ui/world_text_plate.tres")
const KEY_STYLE := preload("res://resources/ui/world_keycap.tres")
const FONT_SIZE := 8
const MAX_ROW_WIDTH := 144.0
const KEYS := ["K", "E", "X", "F", "J", "I", "A", "D", "TAB", "ESPACIO", "ENTER"]

var source: Label
var last_text := ""
var rows := VBoxContainer.new()

func bind(label: Label) -> void:
	source = label
	source.self_modulate.a = 0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", PLATE_STYLE)
	add_child(rows)
	rows.add_theme_constant_override("separation", 1)
	source.tree_exiting.connect(queue_free)
	_process(0)

func _process(_delta: float) -> void:
	if not is_instance_valid(source):
		return
	var transform := source.get_global_transform_with_canvas()
	var origin := transform.origin.round()
	visible = source.is_visible_in_tree() and not source.text.is_empty() and Rect2(-360, -70, 1000, 430).has_point(origin)
	if not visible:
		return
	if last_text != source.text:
		last_text = source.text
		_rebuild_rows()
	if source.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER:
		origin.x += roundf((source.size.x * transform.get_scale().x - size.x) / 2)
	position = origin

func _rebuild_rows() -> void:
	for child in rows.get_children():
		rows.remove_child(child)
		child.queue_free()
	var font := source.get_theme_font("font")
	var has_key := false
	for word in last_text.replace("\n", " ").split(" ", false):
		has_key = has_key or word.to_upper() in KEYS
	if not has_key:
		_add_plain_row(last_text)
		reset_size()
		return
	for source_line in last_text.split("\n"):
		for words: PackedStringArray in _wrap_words(source_line, font):
			var row_has_key := false
			for word in words:
				row_has_key = row_has_key or word.to_upper() in KEYS
			if not row_has_key:
				_add_plain_row(" ".join(words))
				continue
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 1)
			rows.add_child(row)
			for index in words.size():
				var word := words[index]
				var glyph := Label.new()
				glyph.text = (" " if index > 0 and word.to_upper() not in KEYS and words[index - 1].to_upper() not in KEYS else "") + word
				glyph.add_theme_font_size_override("font_size", FONT_SIZE)
				glyph.set_meta("world_pixel_font", true)
				_apply_pixel_shadow(glyph)
				if word.to_upper() in KEYS:
					var cap := PanelContainer.new()
					cap.add_theme_stylebox_override("panel", KEY_STYLE)
					cap.add_child(glyph)
					row.add_child(cap)
				else:
					row.add_child(glyph)
	reset_size()

func _add_plain_row(text: String) -> void:
	var text_row := Label.new()
	text_row.text = text
	text_row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var font := source.get_theme_font("font")
	var longest := 0.0
	for line in text.split("\n"):
		longest = maxf(longest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x)
	text_row.custom_minimum_size.x = minf(MAX_ROW_WIDTH, ceilf(longest))
	text_row.horizontal_alignment = source.horizontal_alignment
	text_row.add_theme_font_size_override("font_size", FONT_SIZE)
	text_row.set_meta("world_pixel_font", true)
	text_row.add_theme_constant_override("line_spacing", 0)
	_apply_pixel_shadow(text_row)
	rows.add_child(text_row)

func _apply_pixel_shadow(label: Label) -> void:
	label.add_theme_color_override("font_shadow_color", Color(0.015, 0.025, 0.06, 0.95))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 1)

func _wrap_words(line: String, font: Font) -> Array[PackedStringArray]:
	var result: Array[PackedStringArray] = []
	var current := PackedStringArray()
	var current_width := 0.0
	for word in line.split(" ", false):
		var word_width := _word_width(word, font)
		var added_width := word_width + (1.0 if not current.is_empty() else 0.0)
		if not current.is_empty() and current_width + added_width > MAX_ROW_WIDTH:
			result.append(current)
			current = PackedStringArray()
			current_width = 0.0
			added_width = word_width
		current.append(word)
		current_width += added_width
	if not current.is_empty():
		result.append(current)
	return result

func _word_width(word: String, font: Font) -> float:
	var width := font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
	return width + (4.0 if word.to_upper() in KEYS else 0.0)
