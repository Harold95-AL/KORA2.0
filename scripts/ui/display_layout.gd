extends RefCounted
const SCALE := 1.0

const THEME = preload("res://resources/ui/full_hd_theme.tres")
const CONSTANTS := ["separation","h_separation","v_separation","line_spacing","outline_size"]

static func apply(root: Node) -> void:
	var controls: Array[Dictionary] = []
	_collect(root,controls)
	# Capturar todas las medidas antes de cambiar mínimos y fuentes heredadas.
	for entry in controls:
		var control: Control = entry.node
		control.set_meta("full_hd_layout",true)
		control.theme = THEME
		control.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		control.custom_minimum_size = entry.minimum*SCALE
		if entry.font > 0: control.add_theme_font_size_override("font_size",maxi(8, roundi(entry.font / 8.0) * 8))
		for key in entry.constants:
			control.add_theme_constant_override(key,entry.constants[key])
	for entry in controls:
		var control: Control = entry.node
		control.offset_left = entry.rect.x*SCALE
		control.offset_top = entry.rect.y*SCALE
		control.offset_right = entry.rect.z*SCALE
		control.offset_bottom = entry.rect.w*SCALE

static func _collect(node: Node, entries: Array[Dictionary]) -> void:
	if node is Control and not node.has_meta("full_hd_layout"):
		var constants := {}
		for key in CONSTANTS:
			if node.has_theme_constant_override(key): constants[key] = node.get_theme_constant(key)
		entries.append({"node":node,"rect":Vector4(node.offset_left,node.offset_top,node.offset_right,node.offset_bottom),"minimum":node.custom_minimum_size,"font":node.get_theme_font_size("font_size") if node.has_theme_font_size_override("font_size") else 0,"constants":constants})
	for child in node.get_children(): _collect(child,entries)
