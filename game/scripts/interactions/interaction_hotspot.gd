class_name InteractionHotspot
extends Button

## A scene-space discovery target. It keeps Button's focus and 44pt touch
## semantics, but renders as a hand-drawn point of interest instead of app UI.

const INK := Color("f0d89d")
const INK_SOFT := Color(0.94, 0.85, 0.62, 0.42)
const FOUND := Color("a9d9bc")
const PropAtlas = preload("res://scripts/interactions/interaction_prop_atlas.gd")

var hotspot_id := ""
var display_label := ""
var prop_texture: Texture2D
var _prop_view: TextureRect
var _found := false
var _pulse := 0.0
var _hovered := false
var _hold_progress := -1.0
var _presentation_mode := "sprite"
var _uses_external_asset := false


func setup(id: String, label_text: String) -> void:
	hotspot_id = id
	display_label = label_text
	text = ""
	# Window interactions use the window already painted into the scene. The
	# hotspot becomes a large transparent pane instead of adding a second icon.
	prop_texture = null if id == "window" else PropAtlas.texture_for(id)
	_install_prop_view()
	tooltip_text = label_text
	custom_minimum_size = Vector2(150.0, 120.0)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	flat = true
	add_theme_stylebox_override("normal", _empty_style())
	add_theme_stylebox_override("hover", _empty_style())
	add_theme_stylebox_override("pressed", _empty_style())
	add_theme_stylebox_override("disabled", _empty_style())
	add_theme_stylebox_override("focus", _focus_style())
	pressed.connect(_play_touch_feedback)
	mouse_entered.connect(func() -> void: _hovered = true; queue_redraw())
	mouse_exited.connect(func() -> void: _hovered = false; queue_redraw())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	queue_redraw()


func set_found(value: bool) -> void:
	_found = value
	queue_redraw()


func set_hold_progress(value: float) -> void:
	_hold_progress = value
	queue_redraw()


func set_scene_presentation(mode: String) -> void:
	_presentation_mode = mode
	if _prop_view != null:
		_prop_view.visible = mode != "region"
	queue_redraw()


func set_scene_visual(asset_path: String, visual_size: Vector2) -> void:
	if not asset_path.is_empty() and ResourceLoader.exists(asset_path):
		var loaded := load(asset_path) as Texture2D
		if loaded != null:
			prop_texture = loaded
			_uses_external_asset = true
			_install_prop_view()
	_apply_visual_size(visual_size)


func _play_touch_feedback() -> void:
	_pulse = 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(func(value: float) -> void:
		_pulse = value
		queue_redraw()
	, 0.0, 1.0, 0.24)


func _draw() -> void:
	var center := size * 0.5
	if _presentation_mode == "region" or hotspot_id == "window":
		_draw_window_region()
		return
	if prop_texture == null:
		if _hovered or has_focus() or (_pulse > 0.0 and _pulse < 1.0):
			_draw_unmapped_silhouette(center)
	var base_radius := clampf(minf(size.x, size.y) * 0.38, 22.0, 42.0)
	var ink := FOUND if _found else INK
	if _hovered or has_focus():
		draw_arc(center, base_radius, -0.3, TAU - 0.52, 32, Color(ink, 0.82), 2.2, true)
		draw_arc(center + Vector2(2.0, -1.0), base_radius + 5.0, 2.4, 5.55, 18, INK_SOFT, 1.2, true)
		draw_string(ThemeDB.fallback_font, Vector2(4.0, size.y - 3.0), display_label, HORIZONTAL_ALIGNMENT_CENTER, size.x - 8.0, 14, Color(0.98, 0.95, 0.86, 0.94))
	if _found:
		draw_polyline(PackedVector2Array([
			center + Vector2(-8.0, 0.0), center + Vector2(-2.0, 7.0), center + Vector2(10.0, -8.0),
		]), FOUND, 2.8, true)
	if _pulse > 0.0 and _pulse < 1.0:
		draw_arc(center, base_radius + 7.0 + 25.0 * _pulse, 0.0, TAU, 36, Color(INK, 0.78 * (1.0 - _pulse)), 2.5, true)
	if _hold_progress >= 0.0:
		draw_arc(center, base_radius + 8.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(_hold_progress, 0.0, 1.0), 36, INK, 4.0, true)


func _draw_unmapped_silhouette(center: Vector2) -> void:
	# Non-atlas semantic actions stay unobtrusive and never fall back to a
	# universal circle/button. Their irregular mark is only a spatial affordance.
	var points := PackedVector2Array([
		center + Vector2(-20.0, 11.0), center + Vector2(-10.0, -17.0),
		center + Vector2(8.0, -23.0), center + Vector2(23.0, -2.0),
		center + Vector2(13.0, 19.0), center + Vector2(-8.0, 22.0),
		center + Vector2(-20.0, 11.0),
	])
	draw_polyline(points, Color(0.94, 0.85, 0.65, 0.46), 2.0, true)


func _draw_window_region() -> void:
	var active := _hovered or has_focus() or (_pulse > 0.0 and _pulse < 1.0)
	if not active:
		return
	var pane := Rect2(Vector2(6.0, 6.0), size - Vector2(12.0, 12.0))
	var color := Color(0.78, 0.9, 0.87, 0.62)
	draw_line(pane.position, Vector2(pane.end.x, pane.position.y), color, 2.0)
	draw_line(Vector2(pane.end.x, pane.position.y), pane.end, color, 2.0)
	draw_line(pane.end, Vector2(pane.position.x, pane.end.y), color, 2.0)
	draw_line(Vector2(pane.position.x, pane.end.y), pane.position, color, 2.0)
	if _pulse > 0.0 and _pulse < 1.0:
		draw_arc(size * 0.5, 26.0 + 54.0 * _pulse, 0.0, TAU, 36, Color(INK, 0.75 * (1.0 - _pulse)), 2.8, true)


func _install_prop_view() -> void:
	if _prop_view != null:
		remove_child(_prop_view)
		_prop_view.queue_free()
		_prop_view = null
	if prop_texture == null:
		return
	_prop_view = TextureRect.new()
	_prop_view.texture = prop_texture
	_prop_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_prop_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_prop_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prop_view.show_behind_parent = true
	_prop_view.material = null if _uses_external_asset else PropAtlas.key_material()
	add_child(_prop_view)
	_prop_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_prop_view.visible = _presentation_mode != "region"


func _apply_visual_size(visual_size: Vector2) -> void:
	if _prop_view == null:
		return
	if visual_size.x <= 0.0 or visual_size.y <= 0.0:
		_prop_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		return
	_prop_view.set_anchor(SIDE_LEFT, 0.5)
	_prop_view.set_anchor(SIDE_RIGHT, 0.5)
	_prop_view.set_anchor(SIDE_TOP, 0.5)
	_prop_view.set_anchor(SIDE_BOTTOM, 0.5)
	_prop_view.offset_left = -visual_size.x * 0.5
	_prop_view.offset_right = visual_size.x * 0.5
	_prop_view.offset_top = -visual_size.y * 0.5
	_prop_view.offset_bottom = visual_size.y * 0.5


func _empty_style() -> StyleBoxEmpty:
	return StyleBoxEmpty.new()


func _focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.83, 0.53, 0.06)
	style.border_color = Color(0.95, 0.83, 0.53, 0.72)
	style.set_border_width_all(2)
	style.set_corner_radius_all(30)
	return style
