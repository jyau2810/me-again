class_name SceneLayoutCalibrator
extends Control

const LayoutStore = preload("res://scripts/interactions/interaction_scene_layout_store.gd")
const LAYER_SHADER = preload("res://shaders/visual_layer_treatment.gdshader")
const PREVIEW_SIZE := Vector2(360.0, 640.0)
const DEFAULT_CANVAS_SIZE := Vector2(720.0, 1280.0)

@export var scene_id := "c01_s02_commute_window"

var _layout: Dictionary = {}
var _logical_size := DEFAULT_CANVAS_SIZE
var _selected_id := ""
var _handles: Dictionary = {}
var _synchronizing := false
var _dirty := false

var _canvas: Control
var _background_view: TextureRect
var _target_selector: OptionButton
var _anchor_x: SpinBox
var _anchor_y: SpinBox
var _visual_width: SpinBox
var _visual_height: SpinBox
var _hit_width: SpinBox
var _hit_height: SpinBox
var _z_index: SpinBox
var _mode_selector: OptionButton
var _asset_path: LineEdit
var _locked: CheckBox
var _status_label: Label
var _file_label: Label


class CalibrationHandle extends Control:
	signal selected(target_id: String)
	signal anchor_dragged(target_id: String, anchor: Vector2)

	var target_id := ""
	var display_label := ""
	var anchor := Vector2(0.5, 0.5)
	var hit_size := Vector2(120.0, 120.0)
	var visual_size := Vector2.ZERO
	var logical_size := DEFAULT_CANVAS_SIZE
	var asset_texture: Texture2D
	var is_selected := false
	var locked := false
	var mode := "sprite"
	var _dragging := false
	var _drag_origin_global := Vector2.ZERO
	var _drag_origin_anchor := Vector2.ZERO
	var _hit_rect := Rect2()
	var _visual_rect := Rect2()
	var _asset_view: TextureRect


	func configure(id: String, source: Dictionary, canvas_size: Vector2) -> void:
		target_id = id
		display_label = String(source.get("display_label", id))
		anchor = source.get("anchor", Vector2(0.5, 0.5))
		hit_size = source.get("hit_size", Vector2(120.0, 120.0))
		visual_size = source.get("visual_size", Vector2.ZERO)
		logical_size = source.get("canvas_size", DEFAULT_CANVAS_SIZE)
		locked = bool(source.get("locked", false))
		mode = String(source.get("mode", "sprite"))
		asset_texture = null
		var asset_path := String(source.get("asset_path", ""))
		if not asset_path.is_empty() and ResourceLoader.exists(asset_path):
			asset_texture = load(asset_path) as Texture2D
		_configure_asset_view(source)
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_ALL
		tooltip_text = "%s%s" % [display_label, "（已锁定）" if locked else ""]
		_refresh_geometry(canvas_size)


	func set_selected(value: bool) -> void:
		is_selected = value
		queue_redraw()


	func _refresh_geometry(canvas_size: Vector2) -> void:
		var scale := Vector2(
			canvas_size.x / maxf(logical_size.x, 1.0),
			canvas_size.y / maxf(logical_size.y, 1.0)
		)
		var scaled_hit := Vector2(hit_size.x * scale.x, hit_size.y * scale.y)
		var scaled_visual := Vector2(visual_size.x * scale.x, visual_size.y * scale.y)
		var display_size := Vector2(
			maxf(36.0, maxf(scaled_hit.x, scaled_visual.x)),
			maxf(36.0, maxf(scaled_hit.y, scaled_visual.y))
		)
		size = display_size
		position = anchor * canvas_size - display_size * 0.5
		_hit_rect = Rect2((display_size - scaled_hit) * 0.5, scaled_hit)
		_visual_rect = Rect2((display_size - scaled_visual) * 0.5, scaled_visual)
		_sync_asset_view_geometry()
		queue_redraw()


	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				selected.emit(target_id)
				grab_focus()
				if not locked:
					_dragging = true
					_drag_origin_global = event.global_position
					_drag_origin_anchor = anchor
				accept_event()
			else:
				_dragging = false
				accept_event()
		elif event is InputEventMouseMotion and _dragging:
			var canvas_size := get_parent_control().size
			var delta: Vector2 = event.global_position - _drag_origin_global
			var next_anchor := _drag_origin_anchor + Vector2(
				delta.x / maxf(canvas_size.x, 1.0),
				delta.y / maxf(canvas_size.y, 1.0)
			)
			next_anchor = next_anchor.clamp(Vector2.ZERO, Vector2.ONE)
			anchor_dragged.emit(target_id, next_anchor)
			accept_event()


	func _draw() -> void:
		var hit_color := Color("f3cc70") if is_selected else Color(0.67, 0.91, 0.82, 0.78)
		var visual_color := Color(0.96, 0.56, 0.36, 0.92)
		if mode == "region":
			draw_rect(_hit_rect, Color(0.32, 0.76, 0.72, 0.12), true)
		if _visual_rect.size.x > 0.0 and _visual_rect.size.y > 0.0:
			draw_rect(_visual_rect, visual_color, false, 1.5)
		if mode != "layer":
			draw_rect(_hit_rect, hit_color, false, 2.5 if is_selected else 1.5)
		var center := size * 0.5
		draw_line(center - Vector2(7.0, 0.0), center + Vector2(7.0, 0.0), hit_color, 1.2)
		draw_line(center - Vector2(0.0, 7.0), center + Vector2(0.0, 7.0), hit_color, 1.2)
		var label_width := minf(size.x, 150.0)
		draw_rect(Rect2(Vector2(0.0, 0.0), Vector2(label_width, 20.0)), Color(0.04, 0.06, 0.07, 0.84), true)
		draw_string(ThemeDB.fallback_font, Vector2(5.0, 15.0), display_label, HORIZONTAL_ALIGNMENT_LEFT, label_width - 10.0, 12, Color.WHITE)
		if locked:
			draw_circle(Vector2(size.x - 9.0, 9.0), 4.0, Color(0.95, 0.72, 0.3, 0.95))


	func _configure_asset_view(source: Dictionary) -> void:
		if _asset_view == null:
			_asset_view = TextureRect.new()
			_asset_view.name = "AssetPreview"
			_asset_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			_asset_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			_asset_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_asset_view.show_behind_parent = true
			add_child(_asset_view)
		_asset_view.texture = asset_texture
		var style: Dictionary = source.get("style", {}).duplicate(true)
		var state_styles: Dictionary = source.get("state_styles", {})
		var highest_alpha := float(style.get("alpha", 1.0))
		for state_value in state_styles.values():
			if state_value is Dictionary and float(state_value.get("alpha", highest_alpha)) >= highest_alpha:
				highest_alpha = float(state_value.get("alpha", highest_alpha))
				style.merge(state_value, true)
		_asset_view.modulate = Color(1.0, 1.0, 1.0, highest_alpha)
		var clip_polygon: Array = source.get("clip_polygon", [])
		var needs_material := not clip_polygon.is_empty()
		needs_material = needs_material or not is_equal_approx(float(style.get("saturation", 1.0)), 1.0)
		needs_material = needs_material or not is_equal_approx(float(style.get("contrast", 1.0)), 1.0)
		needs_material = needs_material or float(style.get("blur", 0.0)) > 0.001
		_asset_view.material = null
		if not needs_material:
			return
		var material := ShaderMaterial.new()
		material.shader = LAYER_SHADER
		material.set_shader_parameter("saturation", float(style.get("saturation", 1.0)))
		material.set_shader_parameter("contrast", float(style.get("contrast", 1.0)))
		material.set_shader_parameter("blur_amount", float(style.get("blur", 0.0)))
		material.set_shader_parameter("use_clip", clip_polygon.size() == 4)
		if clip_polygon.size() == 4:
			var top_left := anchor * logical_size - visual_size * 0.5
			for index in 4:
				var clip_point: Vector2 = clip_polygon[index]
				var local_point: Vector2 = (clip_point - top_left) / visual_size
				material.set_shader_parameter(["clip_a", "clip_b", "clip_c", "clip_d"][index], local_point)
		_asset_view.material = material


	func _sync_asset_view_geometry() -> void:
		if _asset_view == null:
			return
		_asset_view.position = _visual_rect.position
		_asset_view.size = _visual_rect.size


func _ready() -> void:
	_install_tool_theme()
	_build_ui()
	_load_layout()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.ctrl_pressed and event.keycode == KEY_S:
		_save_layout()
		get_viewport().set_input_as_handled()


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color("101719")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 16)
	margin.add_child(columns)

	var preview_column := VBoxContainer.new()
	preview_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_column.add_theme_constant_override("separation", 8)
	columns.add_child(preview_column)

	var heading := Label.new()
	heading.text = "场景布局校准"
	heading.add_theme_font_size_override("font_size", 22)
	heading.add_theme_color_override("font_color", Color("edf2ed"))
	preview_column.add_child(heading)

	var subheading := Label.new()
	subheading.text = "黄色：当前对象　橙色：视觉矩形　绿色：交互命中矩形"
	subheading.add_theme_font_size_override("font_size", 12)
	subheading.add_theme_color_override("font_color", Color("9fb1aa"))
	preview_column.add_child(subheading)

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_column.add_child(center)

	var canvas_panel := PanelContainer.new()
	canvas_panel.custom_minimum_size = PREVIEW_SIZE
	canvas_panel.add_theme_stylebox_override("panel", _panel_style(Color("182124"), Color("5c6b67")))
	center.add_child(canvas_panel)

	_canvas = Control.new()
	_canvas.custom_minimum_size = PREVIEW_SIZE
	_canvas.clip_contents = true
	canvas_panel.add_child(_canvas)

	_background_view = TextureRect.new()
	_background_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background_view.modulate = Color(0.78, 0.78, 0.78, 0.74)
	_background_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.add_child(_background_view)

	var inspector_panel := PanelContainer.new()
	inspector_panel.custom_minimum_size.x = 292.0
	inspector_panel.add_theme_stylebox_override("panel", _panel_style(Color("182124"), Color("33413e")))
	columns.add_child(inspector_panel)

	var inspector_margin := MarginContainer.new()
	inspector_margin.add_theme_constant_override("margin_left", 12)
	inspector_margin.add_theme_constant_override("margin_right", 12)
	inspector_margin.add_theme_constant_override("margin_top", 12)
	inspector_margin.add_theme_constant_override("margin_bottom", 12)
	inspector_panel.add_child(inspector_margin)

	var inspector_scroll := ScrollContainer.new()
	inspector_margin.add_child(inspector_scroll)

	var inspector := VBoxContainer.new()
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector.add_theme_constant_override("separation", 8)
	inspector_scroll.add_child(inspector)

	var inspector_heading := Label.new()
	inspector_heading.text = "对象属性"
	inspector_heading.add_theme_font_size_override("font_size", 18)
	inspector.add_child(inspector_heading)

	_file_label = Label.new()
	_file_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_file_label.add_theme_font_size_override("font_size", 11)
	_file_label.add_theme_color_override("font_color", Color("91a49d"))
	inspector.add_child(_file_label)

	_target_selector = OptionButton.new()
	_target_selector.item_selected.connect(_on_target_selected)
	inspector.add_child(_field("对象", _target_selector))

	_anchor_x = _make_spin(0.0, 1.0, 0.001)
	_anchor_y = _make_spin(0.0, 1.0, 0.001)
	inspector.add_child(_pair_field("中心 X / Y", _anchor_x, _anchor_y))

	_visual_width = _make_spin(0.0, 1280.0, 1.0)
	_visual_height = _make_spin(0.0, 1280.0, 1.0)
	inspector.add_child(_pair_field("视觉 W / H", _visual_width, _visual_height))

	_hit_width = _make_spin(44.0, 1280.0, 1.0)
	_hit_height = _make_spin(44.0, 1280.0, 1.0)
	inspector.add_child(_pair_field("命中 W / H", _hit_width, _hit_height))

	_z_index = _make_spin(-100.0, 100.0, 1.0)
	inspector.add_child(_field("层级", _z_index))

	_mode_selector = OptionButton.new()
	_mode_selector.add_item("sprite")
	_mode_selector.add_item("region")
	_mode_selector.item_selected.connect(func(_index: int) -> void: _on_inspector_changed())
	inspector.add_child(_field("模式", _mode_selector))

	_asset_path = LineEdit.new()
	_asset_path.placeholder_text = "res://assets/art/production/..."
	_asset_path.text_submitted.connect(func(_value: String) -> void: _on_inspector_changed())
	_asset_path.focus_exited.connect(_on_inspector_changed)
	inspector.add_child(_field("资产路径", _asset_path))

	_locked = CheckBox.new()
	_locked.text = "锁定拖动"
	_locked.toggled.connect(func(_value: bool) -> void: _on_inspector_changed())
	inspector.add_child(_locked)

	for spin in [_anchor_x, _anchor_y, _visual_width, _visual_height, _hit_width, _hit_height, _z_index]:
		spin.value_changed.connect(func(_value: float) -> void: _on_inspector_changed())

	var commands := HBoxContainer.new()
	commands.add_theme_constant_override("separation", 8)
	inspector.add_child(commands)

	var save_button := Button.new()
	save_button.text = "保存"
	save_button.tooltip_text = "保存布局（Ctrl+S）"
	save_button.pressed.connect(_save_layout)
	commands.add_child(save_button)

	var reload_button := Button.new()
	reload_button.text = "重新载入"
	reload_button.tooltip_text = "放弃未保存调整并从 JSON 重新载入"
	reload_button.pressed.connect(_load_layout)
	commands.add_child(reload_button)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.add_theme_font_size_override("font_size", 12)
	_status_label.add_theme_color_override("font_color", Color("a9d7bf"))
	inspector.add_child(_status_label)


func _install_tool_theme() -> void:
	var tool_theme := Theme.new()
	var font := load("res://assets/fonts/NotoSansCJKsc-Regular.otf") as Font
	if font != null:
		tool_theme.default_font = font
	tool_theme.default_font_size = 14
	theme = tool_theme


func _load_layout() -> void:
	_layout = LayoutStore.load_scene(scene_id)
	if _layout.is_empty():
		_set_status("无法载入 %s" % LayoutStore.layout_path(scene_id), true)
		return
	_logical_size = _array_vector(_layout.get("canvas_size", []), DEFAULT_CANVAS_SIZE)
	_file_label.text = LayoutStore.layout_path(scene_id)
	_load_reference_background()
	_rebuild_target_selector()
	_rebuild_handles()
	_dirty = false
	if _target_selector.item_count > 0:
		_select_entry(String(_target_selector.get_item_metadata(0)))
	_set_status("已载入；当前坐标尚待场景合成后验收。")


func _load_reference_background() -> void:
	_background_view.texture = null
	var path := String(_layout.get("reference_background_path", ""))
	if not path.is_empty() and ResourceLoader.exists(path):
		_background_view.texture = load(path) as Texture2D


func _rebuild_target_selector() -> void:
	_synchronizing = true
	_target_selector.clear()
	for group in ["targets", "layers"]:
		var entries: Dictionary = _layout.get(group, {})
		var ids := entries.keys()
		ids.sort()
		for id_value in ids:
			var id := String(id_value)
			var entry_key := _entry_key(group, id)
			var prefix := "交互" if group == "targets" else "视觉层"
			_target_selector.add_item("%s · %s" % [prefix, id])
			_target_selector.set_item_metadata(_target_selector.item_count - 1, entry_key)
	_synchronizing = false


func _rebuild_handles() -> void:
	for handle in _handles.values():
		if is_instance_valid(handle):
			handle.queue_free()
	_handles.clear()
	for group in ["targets", "layers"]:
		var entries: Dictionary = _layout.get(group, {})
		for id_value in entries.keys():
			var id := String(id_value)
			var entry_key := _entry_key(group, id)
			var source: Dictionary = entries[id]
			var normalized := _normalize_entry(group, source)
			if normalized.is_empty():
				continue
			normalized["canvas_size"] = _logical_size
			normalized["display_label"] = "%s:%s" % ["T" if group == "targets" else "L", id]
			var handle := CalibrationHandle.new()
			handle.configure(entry_key, normalized, PREVIEW_SIZE)
			handle.selected.connect(_select_entry)
			handle.anchor_dragged.connect(_on_handle_anchor_changed)
			_canvas.add_child(handle)
			handle.z_index = int(normalized.get("z_index", 1)) + 10
			_handles[entry_key] = handle


func _select_entry(entry_key: String) -> void:
	if _entry_source(entry_key).is_empty():
		return
	_selected_id = entry_key
	for id in _handles:
		_handles[id].set_selected(String(id) == entry_key)
	for index in _target_selector.item_count:
		if String(_target_selector.get_item_metadata(index)) == entry_key:
			_synchronizing = true
			_target_selector.select(index)
			_synchronizing = false
			break
	_sync_inspector()


func _on_target_selected(index: int) -> void:
	if _synchronizing:
		return
	_select_entry(String(_target_selector.get_item_metadata(index)))


func _sync_inspector() -> void:
	var source := _entry_source(_selected_id)
	if source.is_empty():
		return
	_synchronizing = true
	var is_layer := _entry_group(_selected_id) == "layers"
	var anchor := _array_vector(source.get("anchor", []), Vector2(0.5, 0.5))
	var visual := _array_vector(source.get("visual_size", []), Vector2.ZERO)
	var hit := visual if is_layer else _array_vector(source.get("hit_size", []), Vector2(120.0, 120.0))
	_anchor_x.value = anchor.x
	_anchor_y.value = anchor.y
	_visual_width.value = visual.x
	_visual_height.value = visual.y
	_hit_width.value = hit.x
	_hit_height.value = hit.y
	_hit_width.editable = not is_layer
	_hit_height.editable = not is_layer
	_z_index.value = int(source.get("z_index", 1))
	_mode_selector.select(1 if String(source.get("mode", "sprite")) == "region" else 0)
	_mode_selector.disabled = is_layer
	_asset_path.text = String(source.get("asset_path", ""))
	_locked.button_pressed = bool(source.get("locked", false))
	_synchronizing = false


func _on_inspector_changed() -> void:
	if _synchronizing or _selected_id.is_empty():
		return
	var group := _entry_group(_selected_id)
	var id := _entry_id(_selected_id)
	var entries: Dictionary = _layout.get(group, {})
	var source: Dictionary = entries.get(id, {}).duplicate(true)
	source["anchor"] = [_rounded(_anchor_x.value), _rounded(_anchor_y.value)]
	source["visual_size"] = [roundi(_visual_width.value), roundi(_visual_height.value)]
	source["z_index"] = roundi(_z_index.value)
	source["asset_path"] = _asset_path.text.strip_edges()
	source["locked"] = _locked.button_pressed
	if group == "targets":
		source["hit_size"] = [roundi(_hit_width.value), roundi(_hit_height.value)]
		source["mode"] = _mode_selector.get_item_text(_mode_selector.selected)
	entries[id] = source
	_layout[group] = entries
	_dirty = true
	_refresh_handle(_selected_id)
	_set_status("有未保存调整。")


func _on_handle_anchor_changed(entry_key: String, anchor: Vector2) -> void:
	var group := _entry_group(entry_key)
	var id := _entry_id(entry_key)
	var entries: Dictionary = _layout.get(group, {})
	var source: Dictionary = entries.get(id, {}).duplicate(true)
	source["anchor"] = [_rounded(anchor.x), _rounded(anchor.y)]
	entries[id] = source
	_layout[group] = entries
	_dirty = true
	_refresh_handle(entry_key)
	if entry_key == _selected_id:
		_sync_inspector()
	_set_status("有未保存调整。")


func _refresh_handle(entry_key: String) -> void:
	var old_handle: CalibrationHandle = _handles.get(entry_key)
	if old_handle == null:
		return
	var group := _entry_group(entry_key)
	var source := _entry_source(entry_key)
	var normalized := _normalize_entry(group, source)
	if normalized.is_empty():
		return
	normalized["canvas_size"] = _logical_size
	normalized["display_label"] = "%s:%s" % ["T" if group == "targets" else "L", _entry_id(entry_key)]
	old_handle.configure(entry_key, normalized, PREVIEW_SIZE)
	old_handle.z_index = int(normalized.get("z_index", 1)) + 10
	old_handle.set_selected(entry_key == _selected_id)


func _normalize_entry(group: String, source: Dictionary) -> Dictionary:
	if group == "layers":
		var layer := LayoutStore.normalize_layer(source)
		if layer.is_empty():
			return {}
		layer["hit_size"] = layer["visual_size"]
		layer["mode"] = "layer"
		return layer
	var target := LayoutStore.normalize_target(source)
	if not target.is_empty():
		target["visual_size"] = _array_vector(source.get("visual_size", []), Vector2.ZERO)
	return target


func _entry_key(group: String, id: String) -> String:
	return "%s:%s" % [group, id]


func _entry_group(entry_key: String) -> String:
	return entry_key.get_slice(":", 0)


func _entry_id(entry_key: String) -> String:
	return entry_key.get_slice(":", 1)


func _entry_source(entry_key: String) -> Dictionary:
	var entries: Dictionary = _layout.get(_entry_group(entry_key), {})
	var source: Variant = entries.get(_entry_id(entry_key), {})
	return source if source is Dictionary else {}


func _save_layout() -> void:
	if _layout.is_empty():
		return
	var path := LayoutStore.layout_path(scene_id)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_set_status("保存失败：%s" % FileAccess.get_open_error(), true)
		return
	file.store_string(JSON.stringify(_layout, "\t") + "\n")
	file.close()
	_dirty = false
	_set_status("已保存。正式运行时会读取同一份布局。")


func _make_spin(minimum: float, maximum: float, step: float) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step
	spin.allow_greater = false
	spin.allow_lesser = false
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return spin


func _field(label_text: String, control: Control) -> VBoxContainer:
	var field := VBoxContainer.new()
	field.add_theme_constant_override("separation", 3)
	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color("aebdb8"))
	field.add_child(label)
	field.add_child(control)
	return field


func _pair_field(label_text: String, first: Control, second: Control) -> VBoxContainer:
	var field := VBoxContainer.new()
	field.add_theme_constant_override("separation", 3)
	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color("aebdb8"))
	field.add_child(label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(first)
	row.add_child(second)
	field.add_child(row)
	return field


func _panel_style(color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	return style


func _array_vector(value: Variant, fallback: Vector2) -> Vector2:
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return fallback


func _rounded(value: float) -> float:
	return snappedf(value, 0.0001)


func _set_status(text: String, is_error := false) -> void:
	_status_label.text = text
	_status_label.add_theme_color_override("font_color", Color("e69a8d") if is_error else Color("a9d7bf"))
