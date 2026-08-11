extends SceneTree

## Headless component and input-logic check.
##
## Run from the repository root:
## HOME=/tmp/me-again-godot-home /Applications/Godot.app/Contents/MacOS/Godot \
##   --headless --path game --script res://scripts/interactions/interaction_self_check.gd

const Catalog = preload("res://scripts/content/story_content_catalog.gd")
const ModelScript = preload("res://scripts/interactions/interaction_model.gd")
const BoardScript = preload("res://scripts/interactions/interaction_board.gd")
const TokenScript = preload("res://scripts/interactions/interaction_drag_token.gd")
const SlotScript = preload("res://scripts/interactions/interaction_drop_slot.gd")
const SurfaceScript = preload("res://scripts/interactions/interaction_gesture_surface.gd")
const LayoutStore = preload("res://scripts/interactions/interaction_scene_layout_store.gd")

var _assertions := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_scene_layout_store()
	_test_all_catalog_contracts_complete()
	_test_gentle_retry_rules()
	await _test_board_renders_every_scene()
	await _test_native_drag_and_drop()
	await _test_trace_pointer_input()
	await _test_real_touch_sequence()
	await process_frame
	await process_frame

	if _failures.is_empty():
		print("PASS: interaction board (%d assertions, 17 renderer contracts)" % _assertions)
		quit(0)
		return
	printerr("FAIL: %d of %d interaction assertions failed" % [_failures.size(), _assertions])
	for failure in _failures:
		printerr("  - %s" % failure)
	quit(1)


func _test_scene_layout_store() -> void:
	var sample_path := LayoutStore.layout_path("c01_s02_commute_window")
	_expect(FileAccess.file_exists(sample_path), "sample scene layout JSON exists")
	var sample := LayoutStore.load_scene("c01_s02_commute_window")
	_expect(not sample.is_empty(), "sample scene layout JSON parses")
	_expect(sample.get("scene_id") == "c01_s02_commute_window", "sample scene ID matches its file")
	_expect(sample.get("targets", {}).size() == 4, "sample scene exposes four calibrated targets")
	_expect(sample.get("layers", {}).size() == 2, "sample scene exposes two independent visual layers")

	var phone := LayoutStore.target("c01_s02_commute_window", "phone")
	_expect(not phone.is_empty(), "runtime resolves a target from JSON")
	_expect(phone.get("anchor", Vector2.ZERO).is_equal_approx(Vector2(0.535, 0.764)), "JSON anchor becomes scene-space Vector2")
	_expect(phone.get("hit_size", Vector2.ZERO) == Vector2(180.0, 180.0), "JSON hit size is preserved")
	_expect(phone.get("visual_size", Vector2.ZERO) == Vector2(105.0, 140.0), "visual size remains independent from hit size")
	_expect(phone.get("mode") == "sprite", "JSON sprite presentation is normalized")

	var armrest := LayoutStore.layer("c01_s02_commute_window", "seat_armrest_occluder")
	_expect(not armrest.is_empty(), "runtime resolves a non-interactive visual layer from JSON")
	_expect(armrest.get("anchor", Vector2.ZERO).is_equal_approx(Vector2(0.1775, 0.5105)), "visual layer anchor becomes scene-space Vector2")
	_expect(armrest.get("visual_size", Vector2.ZERO) == Vector2(256.0, 77.0), "cropped visual layer keeps its authored display size")
	_expect(armrest.get("source_rect", []) == [0, 803, 334, 101], "visual layer retains extraction coordinates for reproducible placement")
	_expect(LayoutStore.layer("c01_s02_commute_window", "missing_layer").is_empty(), "unknown visual layer resolves empty")

	var fallback := LayoutStore.target("c01_s01_room_morning", "alarm")
	_expect(not fallback.is_empty(), "unmigrated scene falls back to the historical layout")
	_expect(fallback.get("anchor", Vector2.ZERO).is_equal_approx(Vector2(0.13, 0.67)), "fallback keeps the historical anchor")
	_expect(fallback.get("mode") == "sprite", "legacy prop mode normalizes to sprite")
	_expect(LayoutStore.target("missing_scene", "missing_target").is_empty(), "unknown target resolves to an empty placement")

	_expect(LayoutStore.decode_scene("{broken", "c01_s02_commute_window").is_empty(), "malformed layout JSON is rejected")
	var minimal := LayoutStore.decode_scene('{"scene_id":"sample","targets":{}}', "sample")
	_expect(not minimal.is_empty(), "valid minimal layout JSON is accepted")
	_expect(LayoutStore.decode_scene('{"scene_id":"other","targets":{}}', "sample").is_empty(), "mismatched scene ID is rejected")
	_expect(LayoutStore.decode_scene('{"scene_id":"sample","targets":{},"layers":[]}', "sample").is_empty(), "non-dictionary visual layers are rejected")
	_expect(LayoutStore.normalize_target({"anchor": [0.5, 0.5]}).is_empty(), "target without a hit size is rejected")


func _test_all_catalog_contracts_complete() -> void:
	var seen_types: Array[String] = []
	for scene_id in Catalog.get_scene_ids():
		var scene: Dictionary = Catalog.get_scene(scene_id)
		var model = ModelScript.new()
		model.configure(scene)
		_expect(model.is_supported(), "%s uses a supported renderer" % scene_id)
		_complete_model(model, scene)
		_expect(model.is_completed(), "%s can complete through its real contract" % scene_id)
		var interaction_type := String(scene.get("interaction_type", ""))
		if not seen_types.has(interaction_type):
			seen_types.append(interaction_type)
	_expect(seen_types.size() == 17, "catalog exercises all 17 renderer contracts")
	for expected_type in ModelScript.SUPPORTED_TYPES:
		_expect(seen_types.has(expected_type), "%s has a catalog scene" % expected_type)


func _complete_model(model, scene: Dictionary) -> void:
	var kind := String(scene.get("interaction_type", ""))
	var contract: Dictionary = scene.get("interaction", {})
	match kind:
		"hotspot_sequence", "collect_clues", "compare_spaces":
			for target_id in _strings(contract.get("target_ids", [])):
				model.dispatch("tap", target_id)
				if model.is_completed():
					break
			if not model.is_completed():
				model.dispatch("tap", String(contract.get("finish_target_id", "")))
		"repeat_observe":
			var target_id := _strings(contract.get("target_ids", []))[0]
			for _index in int(contract.get("repeat_count", 1)):
				model.dispatch("tap", target_id)
		"sort_targets", "slot_placement":
			var assignments: Dictionary = contract.get("assignments", {})
			for item_id in assignments.keys():
				model.dispatch("drop", String(item_id), {"slot_id": String(assignments[item_id])})
		"path_route":
			model.dispatch("route", String(contract.get("handle_id", "")), {
				"success": true, "hit_blocker": false, "accuracy": 0.86,
			})
		"rhythm_sequence":
			for input_id in _strings(contract.get("required_order", [])):
				model.dispatch("tap", input_id)
		"echo_revisit":
			var targets := _strings(contract.get("target_ids", []))
			var needed := int(contract.get("required_count", targets.size()))
			for index in mini(needed, targets.size()):
				model.dispatch("tap", targets[index])
			for action_id in _strings(contract.get("required_actions", [])):
				model.dispatch("special", action_id)
			var finish_id := String(contract.get("finish_target_id", ""))
			if not finish_id.is_empty():
				model.dispatch("hold", finish_id, {"seconds": float(contract.get("hold_seconds", 1.0))})
		"repeat_path":
			var lap_count := int(contract.get("repeat_count", 1))
			for lap_index in lap_count:
				model.dispatch("lap", String(contract.get("path_id", "")), {
					"duration": 2.2 if lap_index == lap_count - 1 else 1.0,
					"on_track_ratio": 0.9,
				})
		"path_trace":
			var prerequisite := String(contract.get("prerequisite_target_id", ""))
			if not prerequisite.is_empty():
				model.dispatch("tap", prerequisite)
			for clue_id in _strings(contract.get("clue_ids", [])):
				model.dispatch("tap", clue_id)
			model.dispatch("trace", String(contract.get("path_id", "")), {"success": true, "accuracy": 0.8})
		"trace_lines":
			for line_id in _strings(contract.get("line_ids", [])):
				model.dispatch("trace", line_id, {"success": true, "accuracy": 0.78})
		"reorder_sequence":
			var order := _strings(contract.get("required_order", []))
			for index in order.size():
				model.dispatch("drop", order[index], {"index": index})
		"drag_place":
			model.dispatch("drop", String(contract.get("source_id", "")), {
				"slot_id": String(contract.get("slot_id", "")),
			})
		"repeat_toggle":
			var toggle_count := int(contract.get("repeat_count", 1))
			for _index in maxi(0, toggle_count - 1):
				model.dispatch("toggle", String(contract.get("target_id", "")))
			model.dispatch("hold", String(contract.get("target_id", "")), {"seconds": 1.3})
		"posture_sequence":
			for action_id in _strings(contract.get("required_order", [])):
				model.dispatch("posture", action_id, {
					"seconds": float(contract.get("hold_seconds", 3.0)),
				})
		"multi_touch_sequence":
			for action_id in _strings(contract.get("required_order", [])):
				model.dispatch("multi", action_id, {"seconds": 1.0, "touch_points": 2})


func _test_gentle_retry_rules() -> void:
	var sort_model = ModelScript.new()
	sort_model.configure(Catalog.get_scene("c01_s03_night_car_array"))
	var wrong := sort_model.dispatch("drop", "car_round_eye", {"slot_id": "enemy_route"})
	_expect(not wrong["accepted"], "wrong classification is not committed")
	_expect(sort_model.snapshot()["placements"].is_empty(), "wrong classification preserves empty slot state")
	_expect(wrong["tone"] == "gentle", "wrong classification uses gentle feedback")

	var loop_model = ModelScript.new()
	loop_model.configure(Catalog.get_scene("c02_s02_outer_loop"))
	for _index in 3:
		loop_model.dispatch("lap", "outer_wall_loop", {"duration": 1.0, "on_track_ratio": 0.9})
	loop_model.dispatch("lap", "outer_wall_loop", {"duration": 0.5, "on_track_ratio": 0.9})
	_expect(loop_model.snapshot()["lap_count"] == 3, "fast final lap keeps the first three laps")
	loop_model.dispatch("lap", "outer_wall_loop", {"duration": 2.1, "on_track_ratio": 0.9})
	_expect(loop_model.is_completed(), "slow retry completes the final lap")

	var posture_model = ModelScript.new()
	posture_model.configure(Catalog.get_scene("c04_s05_forest_edge_hide"))
	posture_model.dispatch("posture", "drag_inside")
	posture_model.dispatch("posture", "set_narrow_gap")
	posture_model.dispatch("posture", "hold_breath_slow", {"seconds": 1.0})
	_expect(not posture_model.is_completed(), "short breath hold never punishes or auto-completes")
	_expect(posture_model.snapshot()["sequence_index"] == 2, "short hold preserves earlier posture steps")
	posture_model.dispatch("posture", "hold_breath_slow", {"seconds": 3.0})
	_expect(posture_model.is_completed(), "three-second breath hold completes")

	var multi_model = ModelScript.new()
	multi_model.configure(Catalog.get_scene("c05_s05_finger_stage"))
	multi_model.dispatch("multi", "lift", {"touch_points": 2})
	_expect(multi_model.snapshot()["sequence_index"] == 0, "out-of-order two-finger input does not skip a step")
	multi_model.dispatch("multi", "separate", {"touch_points": 2})
	_expect(multi_model.snapshot()["sequence_index"] == 1, "correct multi-touch action advances one step")


func _test_board_renders_every_scene() -> void:
	var board = BoardScript.new()
	board.size = Vector2(680.0, 500.0)
	root.add_child(board)
	await process_frame
	for scene_id in Catalog.get_scene_ids():
		board.configure(Catalog.get_scene(scene_id), ["candy_badge"])
		await process_frame
		_expect(board.get_child_count() == 1, "%s renders one reusable board shell" % scene_id)
		_expect(board.get_interaction_state()["interaction_type"] == Catalog.get_scene(scene_id)["interaction_type"], "%s config reaches board model" % scene_id)
	_expect(board.custom_minimum_size.x <= 680.0, "board fits a 680px-wide host")
	_expect(board.custom_minimum_size.y <= 500.0, "board fits a 500px-high host")
	board.queue_free()
	await process_frame


func _test_native_drag_and_drop() -> void:
	var host := Control.new()
	root.add_child(host)
	var token = TokenScript.new()
	token.setup("rain", "雨声")
	host.add_child(token)
	var slot = SlotScript.new()
	slot.setup("window", "窗边", ["rain"])
	host.add_child(slot)
	await process_frame
	var payload: Variant = token.make_drag_payload()
	_expect(payload is Dictionary, "native drag source returns a dictionary payload")
	_expect(slot._can_drop_data(Vector2.ZERO, payload), "matching native drop slot accepts payload")
	var drops: Array[String] = []
	slot.token_dropped.connect(func(item_id: String, slot_id: String) -> void:
		drops.append("%s:%s" % [item_id, slot_id])
	)
	slot._drop_data(Vector2.ZERO, payload)
	_expect(drops == ["rain:window"], "native drop emits semantic item and slot IDs")
	host.queue_free()
	await process_frame


func _test_trace_pointer_input() -> void:
	var surface = SurfaceScript.new()
	surface.size = Vector2(560.0, 250.0)
	root.add_child(surface)
	await process_frame
	surface.configure_trace(["desk_scratch_path"], true)
	var results: Array[Dictionary] = []
	surface.trace_resolved.connect(func(_line_id: String, data: Dictionary) -> void:
		results.append(data)
	)
	var guide: PackedVector2Array = surface._trace_guide("desk_scratch_path")
	_send_mouse_button(surface, guide[0], true)
	for point in guide:
		var motion := InputEventMouseMotion.new()
		motion.position = point
		surface._gui_input(motion)
	_send_mouse_button(surface, guide[-1], false)
	_expect(results.size() == 1, "pointer trace emits one resolved stroke")
	_expect(results.size() == 1 and results[0]["success"], "wide trace accepts a faithful but sampled stroke")
	surface.queue_free()
	await process_frame


func _test_real_touch_sequence() -> void:
	var surface = SurfaceScript.new()
	# `_gui_input` receives touch coordinates local to the Control, even when the
	# board itself is offset inside the portrait game screen.
	surface.position = Vector2(73.0, 91.0)
	surface.size = Vector2(560.0, 250.0)
	root.add_child(surface)
	await process_frame
	surface.configure_multi(["drag_branch", "tap_shadow", "hold_two_fingers"])
	var actions: Array[String] = []
	surface.multi_gesture.connect(func(action: String, _data: Dictionary) -> void:
		actions.append(action)
	)

	_send_touch(surface, 0, Vector2(100.0, 110.0), true)
	_send_drag(surface, 0, Vector2(190.0, 110.0))
	_send_touch(surface, 0, Vector2(190.0, 110.0), false)
	_expect(actions == ["drag_branch"], "one-finger branch drag is recognized from touch events")

	surface.set_multi_step(1)
	_send_touch(surface, 0, Vector2(260.0, 120.0), true)
	_send_touch(surface, 0, Vector2(260.0, 120.0), false)
	_expect(actions == ["drag_branch", "tap_shadow"], "tree-shadow tap is recognized from touch events")

	surface.set_multi_step(2)
	_send_touch(surface, 0, Vector2(220.0, 120.0), true)
	_send_touch(surface, 1, Vector2(340.0, 120.0), true)
	surface.set("_two_started_msec", Time.get_ticks_msec() - 900)
	surface._process(0.016)
	_expect(actions == ["drag_branch", "tap_shadow", "hold_two_fingers"], "two simultaneous touch points satisfy the hold gesture")
	_send_touch(surface, 0, Vector2(220.0, 120.0), false)
	_send_touch(surface, 1, Vector2(340.0, 120.0), false)
	surface.queue_free()
	await process_frame


func _send_mouse_button(surface, position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = pressed
	surface._gui_input(event)


func _send_touch(surface, index: int, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	surface._gui_input(event)


func _send_drag(surface, index: int, position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position
	surface._gui_input(event)


func _strings(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array or values is PackedStringArray:
		for value in values:
			result.append(String(value))
	return result


func _expect(condition: bool, message: String) -> void:
	_assertions += 1
	if not condition:
		_failures.append(message)
