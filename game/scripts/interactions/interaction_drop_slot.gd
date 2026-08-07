class_name InteractionDropSlot
extends PanelContainer

const PropAtlas = preload("res://scripts/interactions/interaction_prop_atlas.gd")

signal token_dropped(item_id: String, slot_id: String)

var slot_id := ""
var allowed_items: Array[String] = []
var locked := false
var _title_text := ""
var _content_text := ""
var _title_label: Label
var _content_label: Label
var _pulse := 1.0
var _prop_texture: Texture2D
var _prop_view: TextureRect
var _presentation_mode := "prop"
var _region_active := false


func setup(id: String, title: String, accepts: Array[String] = []) -> void:
	slot_id = id
	_title_text = title
	allowed_items = accepts.duplicate()
	_prop_texture = PropAtlas.texture_for(id)
	_install_prop_view()
	tooltip_text = "%s\n这里还空着" % title
	custom_minimum_size = Vector2(128.0, 82.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	if is_node_ready():
		_refresh_labels()


func set_content(label_text: String) -> void:
	_content_text = label_text
	if is_node_ready():
		_refresh_labels()


func clear_content() -> void:
	set_content("")


func set_scene_presentation(mode: String) -> void:
	_presentation_mode = mode
	if _prop_view != null:
		_prop_view.visible = mode == "prop"
	if _title_label != null:
		_title_label.visible = mode != "region"
	if _content_label != null:
		_content_label.visible = mode != "region"
	queue_redraw()


func _ready() -> void:
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)

	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_title_label)

	_content_label = Label.new()
	_content_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content_label.modulate = Color(0.74, 0.92, 0.84)
	_content_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_content_label)
	_refresh_labels()
	queue_redraw()


func _draw() -> void:
	if _presentation_mode == "region":
		if _region_active or _pulse < 1.0:
			draw_rect(Rect2(Vector2(4.0, 4.0), size - Vector2(8.0, 8.0)), Color(0.71, 0.88, 0.79, 0.62), false, 3.0)
		return
	if _is_route_lane():
		_draw_route_lane()
		return
	var center := size * 0.5
	var radius := maxf(25.0, minf(size.x, size.y) * 0.34) + 9.0 * (1.0 - _pulse)
	var color := Color(0.65, 0.86, 0.74, 0.82) if not _content_text.is_empty() else Color(0.91, 0.79, 0.54, 0.58)
	draw_arc(center, radius, 0.2, TAU - 0.15, 28, color, 2.0, true)
	draw_arc(center + Vector2(3.0, -2.0), radius + 6.0, 2.8, 5.9, 15, Color(color, 0.34), 1.0, true)


func _is_route_lane() -> bool:
	return slot_id in ["friend_route", "enemy_route"]


func _draw_route_lane() -> void:
	var friendly := slot_id == "friend_route"
	var color := Color(0.58, 0.84, 0.7, 0.76) if friendly else Color(0.84, 0.54, 0.48, 0.72)
	var top := size.y * 0.28
	var bottom := size.y * 0.78
	var left := 10.0
	var right := size.x - 10.0
	draw_line(Vector2(left, top), Vector2(right, top), Color(color, 0.48), 2.0)
	draw_line(Vector2(left, bottom), Vector2(right, bottom), Color(color, 0.48), 2.0)
	for step in 4:
		var x := lerpf(left + 16.0, right - 36.0, float(step) / 3.0)
		draw_line(Vector2(x, size.y * 0.53), Vector2(x + 25.0, size.y * 0.53), color, 3.0)
	var tip_x := right - 9.0 if friendly else left + 9.0
	var base_x := tip_x - 22.0 if friendly else tip_x + 22.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(tip_x, size.y * 0.53), Vector2(base_x, size.y * 0.40), Vector2(base_x, size.y * 0.66),
	]), color)
	if _pulse < 1.0:
		draw_rect(Rect2(Vector2(4.0, 4.0), size - Vector2(8.0, 8.0)), Color(color, 0.6 * (1.0 - _pulse)), false, 4.0)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if locked or not data is Dictionary:
		_region_active = false
		queue_redraw()
		return false
	var payload: Dictionary = data
	if String(payload.get("kind", "")) != "me_again_interaction_token":
		return false
	var item_id := String(payload.get("item_id", ""))
	var accepted := not item_id.is_empty() and (allowed_items.is_empty() or allowed_items.has(item_id))
	_region_active = accepted
	queue_redraw()
	return accepted


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(_at_position, data):
		return
	var payload: Dictionary = data
	_region_active = false
	_play_drop_feedback()
	token_dropped.emit(String(payload.get("item_id", "")), slot_id)


func _play_drop_feedback() -> void:
	_pulse = 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(func(value: float) -> void:
		_pulse = value
		queue_redraw()
	, 0.0, 1.0, 0.24)


func _install_prop_view() -> void:
	if _prop_texture == null:
		return
	_prop_view = TextureRect.new()
	_prop_view.texture = _prop_texture
	_prop_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_prop_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_prop_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prop_view.show_behind_parent = true
	_prop_view.material = PropAtlas.key_material()
	add_child(_prop_view)
	_prop_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _refresh_labels() -> void:
	if _title_label == null or _content_label == null:
		return
	_title_label.text = _title_text
	_content_label.text = _content_text if not _content_text.is_empty() else ""
	_title_label.visible = _presentation_mode != "region"
	_content_label.visible = _presentation_mode != "region"
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_region_active = false
		queue_redraw()
