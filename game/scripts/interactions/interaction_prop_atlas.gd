class_name InteractionPropAtlas
extends RefCounted

## Central 4x4 prop-atlas registry shared by hotspots, drag sources and slots.
## Missing atlases are intentionally tolerated so content can be generated and
## imported incrementally without changing any interaction contract.

const ROOT := "res://assets/art/props/"
const ATLASES := {
	"everyday": "everyday_props_atlas.png",
	"paper": "paper_props_atlas.png",
	"shelter": "shelter_forest_props_atlas.png",
	"action": "action_props_atlas.png",
}

const CELLS := {
	"alarm": ["everyday", 0], "cup": ["everyday", 1], "shirt": ["everyday", 2], "keys": ["everyday", 3],
	"door_lock": ["everyday", 4], "window": ["everyday", 5], "phone": ["everyday", 6], "red_light": ["everyday", 7],
	"tree": ["everyday", 8], "gate": ["everyday", 9], "track_shadow": ["everyday", 10], "wall_corner": ["everyday", 11],
	"chalk": ["everyday", 12], "star": ["everyday", 13], "desk_corner": ["everyday", 14], "bag": ["everyday", 15],

	"old_manga": ["paper", 0], "pencil": ["paper", 1], "old_paper": ["paper", 2], "round_friend": ["paper", 3],
	"brow_friend": ["paper", 4], "bag_friend": ["paper", 5], "new_book": ["paper", 6], "bookmark": ["paper", 7],
	"receipt": ["paper", 8], "messages": ["paper", 9], "desk_drawer": ["paper", 10], "overhead_light": ["paper", 11],
	"book_cabinet": ["paper", 12], "leaf_cabinet": ["paper", 13], "empty_cabinet": ["paper", 14], "plastic_ruler": ["paper", 15],

	"lamp": ["shelter", 0], "chair": ["shelter", 1], "old_school": ["shelter", 2], "forest_shadow": ["shelter", 3],
	"mud": ["shelter", 4], "drag_branch": ["shelter", 5], "blackboard": ["shelter", 6], "manga_page": ["shelter", 7],
	"cabinet": ["shelter", 8], "fossil_box": ["shelter", 9], "why_book": ["shelter", 10], "old_mud": ["shelter", 11],
	"new_pen": ["shelter", 12], "fossil": ["shelter", 13], "marble": ["shelter", 14], "hold_two_fingers": ["shelter", 15],

	"car_round_eye": ["action", 0], "car_sleepy_eye": ["action", 1], "car_narrow_eye": ["action", 2], "car_red_tail": ["action", 3],
	"car_tiny_van": ["action", 4], "seatbelt_pin": ["action", 5], "green": ["action", 6], "red": ["action", 7],
	"old_bookmark": ["action", 8], "stage_gap": ["action", 9], "rain": ["action", 10], "steps": ["action", 11],
	"breath": ["action", 12], "cabinet_door": ["action", 13],
}

const ALIASES := {
	"red_light": "red_light", "hold_breath_slow": "breath", "forest_shadow_door": "forest_shadow",
	"tap_shadow": "forest_shadow", "drag_inside": "cabinet", "set_narrow_gap": "cabinet_door",
	"fossil_table": "old_mud", "open_manga": "old_manga", "send_friend_message": "phone",
	"arrange_items": "marble", "close_laptop": "overhead_light", "door": "door_lock",
	"headlight": "car_round_eye", "plate": "car_red_tail", "start_loop": "track_shadow",
	"track_line": "track_shadow", "chalk_corridor_shadow": "chalk", "hint_no_turn": "chalk",
	"hint_slow_fourth": "track_shadow", "hint_short_shadow": "tree", "desk_mark": "desk_corner",
	"drawer_note": "desk_drawer", "route_confirm": "door_lock", "panel_corridor": "manga_page",
	"like": "round_friend", "wait": "bag_friend", "proud": "brow_friend", "bye": "bookmark",
}

static var _material: ShaderMaterial


static func texture_for(prop_id: String) -> Texture2D:
	var lookup_id := String(ALIASES.get(prop_id, prop_id))
	if not CELLS.has(lookup_id):
		return null
	var cell: Array = CELLS[lookup_id]
	var atlas_key := String(cell[0])
	var path := ROOT + String(ATLASES.get(atlas_key, ""))
	if not ResourceLoader.exists(path):
		return null
	var atlas: Texture2D = load(path)
	if atlas == null or atlas.get_width() <= 0 or atlas.get_height() <= 0:
		return null
	var index := int(cell[1])
	var region := AtlasTexture.new()
	region.atlas = atlas
	var cell_size := Vector2(atlas.get_width() / 4.0, atlas.get_height() / 4.0)
	region.region = Rect2(Vector2(index % 4, index / 4) * cell_size, cell_size)
	region.filter_clip = true
	return region


static func key_material() -> ShaderMaterial:
	if _material != null:
		return _material
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float brightest = max(source.r, max(source.g, source.b));
	float darkest = min(source.r, min(source.g, source.b));
	float chroma = brightest - darkest;
	float luma = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	float neutral = 1.0 - smoothstep(0.055, 0.16, chroma);
	float bright = smoothstep(0.68, 0.91, luma);
	float keyed = neutral * bright;
	source.a *= 1.0 - keyed;
	COLOR = source;
}
"""
	_material = ShaderMaterial.new()
	_material.shader = shader
	return _material
