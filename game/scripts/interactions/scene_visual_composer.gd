class_name SceneVisualComposer
extends Control

## Renders the non-interactive visual layers authored in a scene layout JSON.
## The calibrator and the game therefore share one full-canvas coordinate space.

const LayoutStore = preload("res://scripts/interactions/interaction_scene_layout_store.gd")
const LAYER_SHADER = preload("res://shaders/visual_layer_treatment.gdshader")

var _scene_id := ""
var _layer_views: Dictionary = {}
var _layer_asset_paths: Dictionary = {}
var _target_views: Dictionary = {}
var _target_asset_paths: Dictionary = {}


func configure(scene_id: String, include_target_visuals := false) -> void:
	clear_scene()
	_scene_id = scene_id
	var layers := LayoutStore.layers(scene_id)
	var layer_ids := layers.keys()
	layer_ids.sort_custom(func(left: Variant, right: Variant) -> bool:
		var left_layer: Dictionary = layers[left]
		var right_layer: Dictionary = layers[right]
		var left_z := int(left_layer.get("z_index", 0))
		var right_z := int(right_layer.get("z_index", 0))
		return left_z < right_z or (left_z == right_z and String(left) < String(right))
	)
	for layer_value in layer_ids:
		_add_layer(String(layer_value), layers[layer_value])
	if include_target_visuals:
		_add_target_visuals(scene_id)


func clear_scene() -> void:
	for child in get_children():
		child.queue_free()
	_layer_views.clear()
	_layer_asset_paths.clear()
	_target_views.clear()
	_target_asset_paths.clear()
	_scene_id = ""


func set_layer_state(layer_id: String, state_id: String) -> bool:
	var view: TextureRect = _layer_views.get(layer_id)
	if view == null:
		return false
	var path := LayoutStore.layer_asset_path(_scene_id, layer_id, state_id)
	if path.is_empty() or not ResourceLoader.exists(path):
		return false
	var texture := load(path) as Texture2D
	if texture == null:
		return false
	view.texture = texture
	_layer_asset_paths[layer_id] = path
	_apply_layer_style(view, LayoutStore.layer(_scene_id, layer_id), state_id)
	return true


func layer_ids() -> Array[String]:
	var ids: Array[String] = []
	for id_value in _layer_views.keys():
		ids.append(String(id_value))
	ids.sort()
	return ids


func layer_view(layer_id: String) -> TextureRect:
	return _layer_views.get(layer_id)


func layer_asset_path(layer_id: String) -> String:
	return String(_layer_asset_paths.get(layer_id, ""))


func target_view(target_id: String) -> TextureRect:
	return _target_views.get(target_id)


func set_target_state(target_id: String, state_id: String) -> bool:
	var view: TextureRect = _target_views.get(target_id)
	if view == null:
		return false
	var path := LayoutStore.target_asset_path(_scene_id, target_id, state_id)
	if path.is_empty() or not ResourceLoader.exists(path):
		return false
	var texture := load(path) as Texture2D
	if texture == null:
		return false
	view.texture = texture
	_target_asset_paths[target_id] = path
	return true


func target_asset_path(target_id: String) -> String:
	return String(_target_asset_paths.get(target_id, ""))


func _add_layer(layer_id: String, layer: Dictionary) -> void:
	var view := _add_view("Layer_%s" % layer_id, layer)
	if view == null:
		return
	_layer_views[layer_id] = view
	_layer_asset_paths[layer_id] = String(layer.get("asset_path", ""))
	_apply_layer_style(view, layer)


func _add_target_visuals(scene_id: String) -> void:
	var scene_data := LayoutStore.load_scene(scene_id)
	var targets: Dictionary = scene_data.get("targets", {})
	for target_value in targets.keys():
		var target_id := String(target_value)
		var target := LayoutStore.normalize_target(targets[target_value])
		if target.is_empty() or String(target.get("mode", "sprite")) != "sprite":
			continue
		var view := _add_view("Target_%s" % target_id, target)
		if view != null:
			_target_views[target_id] = view
			_target_asset_paths[target_id] = String(target.get("asset_path", ""))


func _add_view(view_name: String, source: Dictionary) -> TextureRect:
	var path := String(source.get("asset_path", ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var texture := load(path) as Texture2D
	if texture == null:
		return null
	var anchor: Vector2 = source.get("anchor", Vector2(0.5, 0.5))
	var visual_size: Vector2 = source.get("visual_size", Vector2.ZERO)
	var view := TextureRect.new()
	view.name = view_name
	view.texture = texture
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.set_anchor(SIDE_LEFT, anchor.x)
	view.set_anchor(SIDE_RIGHT, anchor.x)
	view.set_anchor(SIDE_TOP, anchor.y)
	view.set_anchor(SIDE_BOTTOM, anchor.y)
	view.offset_left = -visual_size.x * 0.5
	view.offset_right = visual_size.x * 0.5
	view.offset_top = -visual_size.y * 0.5
	view.offset_bottom = visual_size.y * 0.5
	view.z_index = int(source.get("z_index", 0))
	add_child(view)
	return view


func _apply_layer_style(view: TextureRect, source: Dictionary, state_id := "") -> void:
	var style := LayoutStore.layer_style(_scene_id, String(view.name).trim_prefix("Layer_"), state_id)
	if style.is_empty():
		style = source.get("style", {})
	view.modulate = Color(1.0, 1.0, 1.0, float(style.get("alpha", 1.0)))
	var clip_polygon: Array[Vector2] = source.get("clip_polygon", [])
	var needs_material := not clip_polygon.is_empty()
	needs_material = needs_material or not is_equal_approx(float(style.get("saturation", 1.0)), 1.0)
	needs_material = needs_material or not is_equal_approx(float(style.get("contrast", 1.0)), 1.0)
	needs_material = needs_material or float(style.get("blur", 0.0)) > 0.001
	if not needs_material:
		view.material = null
		return
	var material := view.material as ShaderMaterial
	if material == null:
		material = ShaderMaterial.new()
		material.shader = LAYER_SHADER
		view.material = material
	material.set_shader_parameter("saturation", float(style.get("saturation", 1.0)))
	material.set_shader_parameter("contrast", float(style.get("contrast", 1.0)))
	material.set_shader_parameter("blur_amount", float(style.get("blur", 0.0)))
	material.set_shader_parameter("use_clip", clip_polygon.size() == 4)
	if clip_polygon.size() != 4:
		return
	var anchor: Vector2 = source.get("anchor", Vector2(0.5, 0.5))
	var visual_size: Vector2 = source.get("visual_size", Vector2.ONE)
	var canvas_size := size
	var top_left := anchor * canvas_size - visual_size * 0.5
	for index in 4:
		var local_point: Vector2 = (clip_polygon[index] - top_left) / visual_size
		material.set_shader_parameter(["clip_a", "clip_b", "clip_c", "clip_d"][index], local_point)
