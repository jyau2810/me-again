# InteractionBoard

`interaction_board.gd` is the reusable Godot 4.7.1 `Control` for all 17
`StoryContentCatalog` renderer contracts. It is built entirely in code, so a
scene host only needs to provide a catalog scene dictionary.

```gdscript
const InteractionBoardScript = preload("res://scripts/interactions/interaction_board.gd")

var board := InteractionBoardScript.new()
board.size = Vector2(680, 500)
add_child(board)
board.completed.connect(_on_completed)
board.feedback_changed.connect(_on_feedback)
board.collectible_requested.connect(_on_collectible)
board.sfx_requested.connect(_on_sfx)
board.configure(scene, already_collected_item_ids)
```

Public integration boundary:

- `configure(scene, already_collected = [])` renders a fresh catalog scene.
- `reset_interaction()` safely starts the current interaction again.
- `submit_action(action, target_id, data)` is the accessibility/replay adapter.
- `get_interaction_state()` and `get_metrics()` return deep-copy runtime data.
- `completed(metrics)` fires exactly once per configuration.
- `feedback_changed(text, tone)` uses calm, warm, gentle and complete tones.
- `collectible_requested(item_id)` omits items already passed to `configure`.
- `sfx_requested(kind)` asks the audio layer for a semantic sound, not a file.
- `interaction_state_changed(state)` lets scene visuals respond to accepted interaction progress without owning game rules.

Scene placement is resolved by `interaction_scene_layout_store.gd`. It first
loads `res://data/scene_layouts/<scene_id>.json` and normalizes `anchor`,
`visual_size`, `hit_size`, `z_index`, `mode`, `asset_path`, optional
`state_asset_paths` / `source_rect`, and `locked` for
interactive targets. The same JSON can contain non-interactive `layers` with
`source_rect`, `anchor`, `visual_size`, `z_index`, `asset_path`, optional
`style` / `state_styles` / `clip_polygon`, and `locked`;
the calibrator edits those layers without inventing hit areas.
Missing files or targets fall back one target at a time to the historical
`interaction_scene_layouts.gd` table, so scenes can migrate independently.
Runtime sprites can use an external transparent asset and a visual rectangle
that is smaller or larger than the forgiving hit rectangle.

`scene_visual_composer.gd` is the runtime consumer for non-interactive `layers`
and asset-backed target visuals whose z order must cross layer boundaries.
`MainApp` uses the JSON `reference_background_path`, mounts the composer across
the full 720 x 1280 canvas, and keeps every visual layer mouse-transparent. It
sorts by authored `z_index` and can switch `state_asset_paths` for both visual
layers and asset-backed targets, such as the commuter's `down` / `look_up` pair,
the headlights' `neutral` / `blink` pair, and the plate's `neutral` /
`mouth_hint` pair, without duplicating placement. Layer style states can also
change alpha while a shared shader applies saturation, contrast, blur and a
four-point hard clip; the child reflection uses this for its hidden, faint and
visible states. The calibrator previews the highest visible style with the same
shader while keeping the layer manually adjustable. The observation field also
spans the same full logical canvas, so saved calibrator anchors do not need an
additional runtime offset.

To calibrate the sample scene, open and run
`res://scenes/tools/scene_layout_calibrator.tscn` in Godot. Select an interactive
target or visual layer on the canvas or in the inspector, drag its center, edit
the fields that belong to that object, then save. The tool and runtime read the same
repository JSON; Ctrl+S saves and Reload discards unsaved changes.

The board uses native Godot drag payloads for classification, sound slots,
storyboard ordering and bookmark placement. Route, slow laps and forgiving
tracing use `interaction_gesture_surface.gd`. Chapter 5 accepts actual
`InputEventScreenTouch` / `InputEventScreenDrag` two-point gestures; the three
visible fallback buttons and number keys 1–3 provide complete mouse and keyboard
alternatives. Long holds show a live countdown, and failed attempts never erase
valid progress.

Run the component and input self-check from the repository root:

```sh
HOME=/tmp/me-again-godot-home \
  /Applications/Godot.app/Contents/MacOS/Godot \
  --headless --path game \
  --script res://scripts/interactions/interaction_self_check.gd
```

The test configures all 30 scenes, completes all 17 renderer contracts, checks
non-punitive retry behavior, instantiates every board layout, validates native
drop payloads, draws a trace with mouse events, and performs the Chapter 5 touch
sequence with screen-touch events. It also validates canonical layout JSON,
independent visual/hit sizes, cropped visual layers, target visual states and
legacy fallback behavior. The expected result is 251 assertions across 17 contracts.
