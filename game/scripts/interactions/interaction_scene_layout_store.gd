class_name InteractionSceneLayoutStore
extends RefCounted

## Loads per-scene production layouts while keeping the historical GDScript
## table available for scenes that have not entered the new art pipeline yet.

const LegacyLayouts = preload("res://scripts/interactions/interaction_scene_layouts.gd")
const LAYOUT_DIRECTORY := "res://data/scene_layouts"


static func layout_path(scene_id: String) -> String:
	if scene_id.is_empty() or not scene_id.is_valid_identifier():
		return ""
	return "%s/%s.json" % [LAYOUT_DIRECTORY, scene_id]


static func load_scene(scene_id: String) -> Dictionary:
	var path := layout_path(scene_id)
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	return decode_scene(FileAccess.get_file_as_string(path), scene_id)


static func decode_scene(json_text: String, expected_scene_id := "") -> Dictionary:
	var json := JSON.new()
	if json.parse(json_text) != OK or not json.data is Dictionary:
		return {}
	var data: Dictionary = json.data
	var scene_id := String(data.get("scene_id", ""))
	if scene_id.is_empty() or (not expected_scene_id.is_empty() and scene_id != expected_scene_id):
		return {}
	if not data.get("targets", {}) is Dictionary:
		return {}
	if data.has("layers") and not data.get("layers") is Dictionary:
		return {}
	return data.duplicate(true)


static func target(scene_id: String, target_id: String) -> Dictionary:
	var scene_data := load_scene(scene_id)
	var targets: Dictionary = scene_data.get("targets", {})
	var authored: Variant = targets.get(target_id)
	if authored is Dictionary:
		var normalized := normalize_target(authored)
		if not normalized.is_empty():
			return normalized
	return _normalize_legacy_target(LegacyLayouts.target(scene_id, target_id))


static func layers(scene_id: String) -> Dictionary:
	var scene_data := load_scene(scene_id)
	var authored_layers: Dictionary = scene_data.get("layers", {})
	var normalized_layers := {}
	for id_value in authored_layers.keys():
		var layer_id := String(id_value)
		var source: Variant = authored_layers.get(id_value)
		if not source is Dictionary:
			continue
		var normalized := normalize_layer(source)
		if not normalized.is_empty():
			normalized_layers[layer_id] = normalized
	return normalized_layers


static func layer(scene_id: String, layer_id: String) -> Dictionary:
	return layers(scene_id).get(layer_id, {}).duplicate(true)


static func normalize_target(source: Dictionary) -> Dictionary:
	var anchor := _vector2(source.get("anchor"), Vector2(-1.0, -1.0))
	var hit_size := _vector2(source.get("hit_size"), Vector2.ZERO)
	if anchor.x < 0.0 or anchor.y < 0.0 or hit_size.x <= 0.0 or hit_size.y <= 0.0:
		return {}
	var mode := String(source.get("mode", "sprite"))
	if mode not in ["sprite", "region"]:
		mode = "sprite"
	return {
		"anchor": anchor,
		"visual_size": _vector2(source.get("visual_size"), hit_size),
		"hit_size": hit_size,
		"z_index": int(source.get("z_index", 1)),
		"mode": mode,
		"asset_path": String(source.get("asset_path", "")),
		"locked": bool(source.get("locked", false)),
	}


static func normalize_layer(source: Dictionary) -> Dictionary:
	var anchor := _vector2(source.get("anchor"), Vector2(-1.0, -1.0))
	var visual_size := _vector2(source.get("visual_size"), Vector2.ZERO)
	var asset_path := String(source.get("asset_path", ""))
	var source_rect := _rect4(source.get("source_rect"))
	if anchor.x < 0.0 or anchor.y < 0.0 or visual_size.x <= 0.0 or visual_size.y <= 0.0:
		return {}
	if asset_path.is_empty():
		return {}
	return {
		"anchor": anchor,
		"visual_size": visual_size,
		"z_index": int(source.get("z_index", 1)),
		"asset_path": asset_path,
		"locked": bool(source.get("locked", false)),
		"source_rect": source_rect,
	}


static func _normalize_legacy_target(source: Dictionary) -> Dictionary:
	if source.is_empty():
		return {}
	var hit_size: Vector2 = source.get("s", Vector2.ZERO)
	if hit_size.x <= 0.0 or hit_size.y <= 0.0:
		return {}
	var legacy_mode := String(source.get("mode", "prop"))
	return {
		"anchor": source.get("p", Vector2(0.5, 0.5)),
		"visual_size": hit_size,
		"hit_size": hit_size,
		"z_index": int(source.get("z", 1)),
		"mode": "region" if legacy_mode == "region" else "sprite",
		"asset_path": "",
		"locked": false,
	}


static func _vector2(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	if value is Dictionary and value.has("x") and value.has("y"):
		return Vector2(float(value["x"]), float(value["y"]))
	return fallback


static func _rect4(value: Variant) -> Array[int]:
	if value is Array and value.size() >= 4:
		return [int(value[0]), int(value[1]), int(value[2]), int(value[3])]
	return []
