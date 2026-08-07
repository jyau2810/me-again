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
sequence with screen-touch events.
