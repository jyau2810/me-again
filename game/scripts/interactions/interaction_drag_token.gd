class_name InteractionDragToken
extends Button

const PropAtlas = preload("res://scripts/interactions/interaction_prop_atlas.gd")

## A keyboard-focusable Godot drag source. Godot's native drag lifecycle is used
## instead of faking drops from button clicks, so mouse and touch drags share the
## same payload and drop validation.

signal drag_started(item_id: String)
signal drag_cancelled(item_id: String)

var item_id := ""
var display_label := ""
var prop_texture: Texture2D
var _prop_view: TextureRect
var _pulse := 1.0
var locked := false:
	set(value):
		locked = value
		disabled = value
		modulate = Color(0.68, 0.72, 0.72, 0.82) if value else Color.WHITE


func setup(id: String, label_text: String) -> void:
	item_id = id
	display_label = label_text
	prop_texture = PropAtlas.texture_for(id)
	_install_prop_view()
	text = ""
	tooltip_text = "%s\n发亮的地方正在等它" % label_text
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	custom_minimum_size = Vector2(104.0, 62.0)
	flat = true
	add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	add_theme_stylebox_override("disabled", StyleBoxEmpty.new())
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button_down.connect(_play_touch_feedback)
	queue_redraw()


func _draw() -> void:
	if prop_texture != null:
		if is_hovered() or has_focus() or _pulse < 1.0:
			draw_arc(size * 0.5, minf(size.x, size.y) * 0.42, 0.0, TAU, 30, Color(0.91, 0.79, 0.54, 0.82), 1.8, true)
		return
	var inset := 5.0 + 2.0 * _pulse
	var paper := PackedVector2Array([
		Vector2(inset + 3.0, inset), Vector2(size.x - inset - 6.0, inset + 2.0),
		Vector2(size.x - inset, size.y - inset - 8.0), Vector2(size.x * 0.56, size.y - inset),
		Vector2(inset, size.y - inset - 4.0),
	])
	draw_colored_polygon(paper, Color(0.18, 0.17, 0.14, 0.54))
	var outline := paper.duplicate()
	outline.append(paper[0])
	draw_polyline(outline, Color(0.91, 0.79, 0.54, 0.82), 1.8, true)
	draw_string(ThemeDB.fallback_font, Vector2(14.0, size.y * 0.58), display_label, HORIZONTAL_ALIGNMENT_CENTER, size.x - 28.0, 15, Color(0.97, 0.94, 0.84))
	draw_line(Vector2(17.0, size.y - 14.0), Vector2(size.x - 18.0, size.y - 16.0), Color(0.91, 0.79, 0.54, 0.38), 1.0)


func _play_touch_feedback() -> void:
	_pulse = 0.0
	var tween := create_tween()
	tween.tween_method(func(value: float) -> void:
		_pulse = value
		queue_redraw()
	, 0.0, 1.0, 0.2)


func _install_prop_view() -> void:
	if prop_texture == null:
		return
	_prop_view = TextureRect.new()
	_prop_view.texture = prop_texture
	_prop_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_prop_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_prop_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prop_view.show_behind_parent = true
	_prop_view.material = PropAtlas.key_material()
	add_child(_prop_view)
	_prop_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if locked or item_id.is_empty():
		return null
	var preview := PanelContainer.new()
	preview.custom_minimum_size = Vector2(112.0, 46.0)
	preview.modulate = Color(1.0, 1.0, 1.0, 0.92)
	var preview_label := Label.new()
	preview_label.text = display_label
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview.add_child(preview_label)
	set_drag_preview(preview)
	drag_started.emit(item_id)
	return make_drag_payload()


func make_drag_payload() -> Dictionary:
	return {
		"kind": "me_again_interaction_token",
		"item_id": item_id,
	}


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and not locked and not is_drag_successful():
		drag_cancelled.emit(item_id)
