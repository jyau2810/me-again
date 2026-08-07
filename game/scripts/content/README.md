# Story content catalog

`story_content_catalog.gd` is the narrative runtime source for all five chapters. It preserves the chapter and scene IDs from `docs/game-script-index.md` and the five chapter scripts, while keeping presentation logic outside the catalog.

## Load and query

```gdscript
const StoryCatalog = preload("res://scripts/content/story_content_catalog.gd")

var chapter_ids := StoryCatalog.get_chapter_ids()
var first_scene_id := StoryCatalog.get_first_scene_id(chapter_ids[0])
var scene := StoryCatalog.get_scene(first_scene_id)
var interaction_type: String = scene["interaction_type"]
var interaction: Dictionary = scene["interaction"]
var next_scene_id := StoryCatalog.get_next_scene_id(first_scene_id)
```

Public query API:

- `get_chapter_ids()` returns the five chapter IDs in story order.
- `has_chapter(id)` and `get_chapter(id)` query chapter metadata.
- `get_scene_ids(chapter_id = "")` returns one chapter or all 30 scene IDs in order.
- `has_scene(id)`, `get_scene(id)` and `get_scenes_for_chapter(chapter_id)` query scene data.
- `get_first_scene_id(chapter_id)` and `get_next_scene_id(scene_id)` support linear progression.
- `get_collectible(id)` returns collectible display metadata.
- `validate_catalog()` returns an empty `PackedStringArray` on success, otherwise human-readable errors.

Every scene contains these stable keys:

`id`, `chapter_id`, `title`, `phase`, `narrative`, `background_key`, `interaction_type`, `interaction`, `objective`, `hint`, `completion_feedback`, `collectibles`, `next_scene_id`.

`interaction_type` selects a reusable UI/interaction renderer. `interaction` supplies its data (targets, count, slots, order, gesture, tolerance or hold time). Query methods return deep copies, so runtime state should be stored separately rather than written into catalog dictionaries.

Renderer contracts:

| `interaction_type` | UI behavior | Main parameters |
| --- | --- | --- |
| `hotspot_sequence` | Visit scene hotspots, then expose a finish target | `target_ids`, `required_count`, `finish_target_id` |
| `repeat_observe` | Revisit one target and advance its visual/text state | `target_ids`, `repeat_count` |
| `sort_targets` | Drag targets into semantic slots | `slots`, `assignments` |
| `path_route` | Drag a route handle while avoiding blockers | `handle_id`, `avoid_ids` |
| `rhythm_sequence` | Tap an ordered input pattern | `input_ids`, `required_order` |
| `echo_revisit` | Revisit changed reality objects, optionally finish with one action | `target_ids`, `required_count`, optional `finish_target_id` |
| `repeat_path` | Traverse one path repeatedly with a final pace rule | `path_id`, `repeat_count`, `final_pace` |
| `path_trace` | Trace a spatial path, optionally after reading clues | `path_id`, optional `clue_ids` |
| `collect_clues` | Find a required subset of scene clues | `target_ids`, `required_count` |
| `trace_lines` | Draw forgiving strokes over guides | `line_ids`, `required_count`, `tolerance` |
| `reorder_sequence` | Drag cards into an exact narrative order | `card_ids`, `required_order` |
| `drag_place` | Drag one source object into one world-space slot | `source_id`, `slot_id` |
| `repeat_toggle` | Open/close one target repeatedly | `target_id`, `repeat_count`, `final_gesture` |
| `slot_placement` | Match sound/object tokens to scene slots | `assignments` |
| `compare_spaces` | Visit several alternatives before proceeding | `target_ids`, `required_count` |
| `posture_sequence` | Perform ordered body/hold gestures | `required_order`, optional `hold_seconds` |
| `multi_touch_sequence` | Perform ordered two-finger gestures | `required_order`, `touch_points` |

## Static self-check

From the project root, after `game/project.godot` exists:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://scripts/content/catalog_self_check.gd
```

The check verifies the exact five-chapter/six-scene shape, required fields, valid phases and interaction types, chapter ownership, collectible acquisition paths, and every `next_scene_id` link. A successful run exits with code 0 and prints the catalog totals.
