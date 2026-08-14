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
const VisualComposerScript = preload("res://scripts/interactions/scene_visual_composer.gd")

var _assertions := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_scene_layout_store()
	_test_all_catalog_contracts_complete()
	_test_gentle_retry_rules()
	_test_repeat_observe_contract()
	await _test_scene_visual_composer()
	await _test_repeat_observe_board_unlocks()
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
	_expect(sample.get("layers", {}).size() == 8, "sample scene exposes eight independent visual layers")
	_expect(LayoutStore.canvas_size("c01_s02_commute_window") == Vector2(720.0, 1280.0), "runtime resolves the authored logical canvas")
	_expect(LayoutStore.reference_background_path("c01_s02_commute_window").ends_with("bg_c01_s02_bus_night_lane_v002.png"), "runtime resolves the approved straight-lane production background")

	var phone := LayoutStore.target("c01_s02_commute_window", "phone")
	_expect(not phone.is_empty(), "runtime resolves a target from JSON")
	_expect(phone.get("anchor", Vector2.ZERO).is_equal_approx(Vector2(0.3448, 0.779)), "JSON anchor becomes scene-space Vector2")
	_expect(phone.get("hit_size", Vector2.ZERO) == Vector2(180.0, 180.0), "JSON hit size is preserved")
	_expect(phone.get("visual_size", Vector2.ZERO) == Vector2(62.0, 105.0), "visual size remains independent from hit size")
	_expect(phone.get("z_index") == 3, "phone renders behind the adult's gripping fingers")
	_expect(phone.get("mode") == "sprite", "JSON sprite presentation is normalized")
	_expect(phone.get("asset_path") == "res://assets/art/production/c01_s02_commute_window/props/prop_phone_commute_cold_v001.png", "confirmed phone resolves its production asset")
	var headlight := LayoutStore.target("c01_s02_commute_window", "headlight")
	_expect(headlight.get("anchor", Vector2.ZERO).is_equal_approx(Vector2(0.7062, 0.4333)), "headlight hotspot is centered on the confirmed lamp housings")
	_expect(headlight.get("visual_size", Vector2.ZERO) == Vector2(157.0, 45.0), "headlight production overlay keeps its source-derived visual size")
	_expect(headlight.get("hit_size", Vector2.ZERO) == Vector2(176.0, 72.0), "headlight keeps a forgiving hit rectangle around the lamp housings")
	_expect(headlight.get("source_rect", []) == [562, 695, 205, 59], "headlight retains its approved-master extraction coordinates")
	_expect(headlight.get("state_asset_paths", {}).size() == 2, "headlight exposes neutral and blink production states")
	_expect(headlight.get("asset_path") == "res://assets/art/production/c01_s02_commute_window/props/prop_vehicle_headlights_neutral_v001.png", "confirmed headlight resolves its production asset")
	_expect(LayoutStore.target_asset_path("c01_s02_commute_window", "headlight", "blink") == "res://assets/art/production/c01_s02_commute_window/props/prop_vehicle_headlights_blink_v001.png", "headlight blink state resolves its production asset")
	var plate := LayoutStore.target("c01_s02_commute_window", "plate")
	_expect(plate.get("anchor", Vector2.ZERO).is_equal_approx(Vector2(0.7242, 0.4542)), "plate hotspot is centered on the actual front plate")
	_expect(plate.get("visual_size", Vector2.ZERO) == Vector2(71.0, 27.0), "plate production overlay keeps its source-derived visual size")
	_expect(plate.get("hit_size", Vector2.ZERO) == Vector2(96.0, 56.0), "plate keeps a forgiving hit rectangle around the small visual")
	_expect(plate.get("source_rect", []) == [635, 742, 93, 35], "plate retains its approved-master extraction coordinates")
	_expect(plate.get("state_asset_paths", {}).size() == 2, "plate exposes neutral and mouth-hint production states")
	_expect(plate.get("asset_path") == "res://assets/art/production/c01_s02_commute_window/props/prop_vehicle_plate_neutral_v001.png", "confirmed plate resolves its production asset")
	_expect(LayoutStore.target_asset_path("c01_s02_commute_window", "plate", "mouth_hint") == "res://assets/art/production/c01_s02_commute_window/props/prop_vehicle_plate_mouth_hint_v001.png", "plate mouth-hint state resolves its production asset")

	var armrest := LayoutStore.layer("c01_s02_commute_window", "seat_armrest_occluder")
	_expect(not armrest.is_empty(), "runtime resolves a non-interactive visual layer from JSON")
	_expect(armrest.get("anchor", Vector2.ZERO).is_equal_approx(Vector2(0.1775, 0.5105)), "visual layer anchor becomes scene-space Vector2")
	_expect(armrest.get("visual_size", Vector2.ZERO) == Vector2(256.0, 77.0), "cropped visual layer keeps its authored display size")
	_expect(armrest.get("source_rect", []) == [0, 803, 334, 101], "visual layer retains extraction coordinates for reproducible placement")
	_expect(armrest.get("z_index") == 2, "seat armrest renders behind the seated adult")
	_expect(armrest.get("locked") == true, "confirmed seat armrest placement is locked")
	var adult := LayoutStore.layer("c01_s02_commute_window", "adult_commuter_down")
	_expect(not adult.is_empty(), "runtime resolves the confirmed low-head adult layer")
	_expect(adult.get("anchor", Vector2.ZERO).is_equal_approx(Vector2(0.2758, 0.677)), "adult keeps its confirmed review placement")
	_expect(adult.get("visual_size", Vector2.ZERO) == Vector2(440.0, 796.0), "adult uses the confirmed tight-crop display size")
	_expect(adult.get("source_rect", []) == [181, 99, 732, 1349], "adult retains its generation-source crop coordinates")
	_expect(adult.get("z_index") == 4, "adult renders above the phone and seat armrest")
	_expect(adult.get("locked") == true, "confirmed adult placement is locked")
	_expect(adult.get("state_asset_paths", {}).size() == 2, "adult exposes two confirmed visual states without duplicating its placement")
	_expect(LayoutStore.layer_asset_path("c01_s02_commute_window", "adult_commuter_down", "look_up").ends_with("char_adult_commuter_seated_look_up_v001.png"), "look-up state resolves its production asset")
	_expect(LayoutStore.layer_asset_path("c01_s02_commute_window", "adult_commuter_down", "missing").ends_with("char_adult_commuter_seated_down_v001.png"), "unknown adult state falls back to the default low-head asset")
	var front_seat := LayoutStore.layer("c01_s02_commute_window", "front_seat_occluder")
	_expect(front_seat.get("z_index") == 7, "front seat remains above the seated adult")
	_expect(front_seat.get("locked") == true, "confirmed front seat placement is locked")
	var vehicle := LayoutStore.layer("c01_s02_commute_window", "vehicle_focus_base")
	_expect(vehicle.get("source_rect", []) == [456, 596, 367, 226], "vehicle body retains its tight extraction coordinates")
	_expect(vehicle.get("visual_size", Vector2.ZERO) == Vector2(281.0, 173.0), "vehicle body converts from review-master pixels to logical size")
	_expect(vehicle.get("locked") == false, "vehicle body remains available for manual correction")
	var grounding := LayoutStore.layer("c01_s02_commute_window", "vehicle_grounding")
	_expect(grounding.get("z_index") == 0, "vehicle grounding renders below the body and glass rain")
	_expect(grounding.get("locked") == false, "vehicle grounding remains independently adjustable")
	var glass_rain := LayoutStore.layer("c01_s02_commute_window", "vehicle_glass_rain")
	_expect(glass_rain.get("z_index") == 3, "vehicle glass rain renders over the vehicle body and its state overlays")
	_expect(glass_rain.get("locked") == false, "vehicle glass rain remains independently adjustable")
	var child := LayoutStore.layer("c01_s02_commute_window", "child_reflection")
	_expect(child.get("anchor", Vector2.ZERO).is_equal_approx(Vector2(0.7662, 0.6944)), "child reflection keeps its confirmed review placement")
	_expect(child.get("visual_size", Vector2.ZERO) == Vector2(225.0, 438.0), "child reflection uses its confirmed tight-crop display size")
	_expect(child.get("locked") == false, "child reflection remains available for manual placement correction")
	_expect(child.get("clip_polygon", []).size() == 4, "child reflection carries a four-point hard glass mask")
	_expect(is_equal_approx(float(LayoutStore.layer_style("c01_s02_commute_window", "child_reflection", "hidden").get("alpha", -1.0)), 0.0), "child reflection is hidden before the second observation")
	_expect(is_equal_approx(float(LayoutStore.layer_style("c01_s02_commute_window", "child_reflection", "faint").get("alpha", -1.0)), 0.11), "second observation uses the faint child reflection state")
	_expect(is_equal_approx(float(LayoutStore.layer_style("c01_s02_commute_window", "child_reflection", "visible").get("alpha", -1.0)), 0.22), "third observation uses the confirmed child reflection strength")
	var warm_reflection := LayoutStore.layer("c01_s02_commute_window", "window_reflection_warm")
	_expect(warm_reflection.get("anchor", Vector2.ZERO).is_equal_approx(Vector2(0.6856, 0.5244)), "warm reflection keeps its confirmed review placement")
	_expect(warm_reflection.get("visual_size", Vector2.ZERO) == Vector2(138.0, 255.0), "warm reflection uses its confirmed tight-crop display size")
	_expect(warm_reflection.get("source_rect", []) == [555, 710, 180, 333], "warm reflection retains its review-master placement coordinates")
	_expect(warm_reflection.get("locked") == false, "warm reflection remains available for manual placement correction")
	_expect(warm_reflection.get("clip_polygon", []).size() == 4, "warm reflection carries a four-point hard glass mask")
	_expect(String(LayoutStore.layer_style("c01_s02_commute_window", "window_reflection_warm").get("blend_mode", "")) == "screen", "warm reflection uses the approved screen blend")
	_expect(is_equal_approx(float(LayoutStore.layer_style("c01_s02_commute_window", "window_reflection_warm", "hidden").get("alpha", -1.0)), 0.0), "warm reflection is hidden before the third observation")
	_expect(is_equal_approx(float(LayoutStore.layer_style("c01_s02_commute_window", "window_reflection_warm", "visible").get("alpha", -1.0)), 0.14), "third observation uses the approved local warmth strength")
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


func _test_scene_visual_composer() -> void:
	var composer = VisualComposerScript.new()
	composer.size = Vector2(720.0, 1280.0)
	root.add_child(composer)
	composer.configure("c01_s02_commute_window", true)
	await process_frame
	_expect(composer.layer_ids().size() == 8, "runtime composer instantiates every authored visual layer")
	var vehicle_view: TextureRect = composer.layer_view("vehicle_focus_base")
	_expect(vehicle_view != null, "runtime composer creates the vehicle body view")
	_expect(vehicle_view.size.is_equal_approx(Vector2(281.0, 173.0)), "runtime vehicle view uses the calibrator visual size")
	_expect(vehicle_view.z_index == 1, "runtime vehicle view keeps its authored z index")
	_expect(composer.layer_view("vehicle_glass_rain").mouse_filter == Control.MOUSE_FILTER_IGNORE, "visual layers never intercept interaction input")
	var phone_view: TextureRect = composer.target_view("phone")
	_expect(phone_view != null, "runtime composer instantiates the independent phone visual")
	_expect(phone_view.z_index == 3 and composer.layer_view("adult_commuter_down").z_index == 4, "phone visual renders below the adult while its hotspot stays interactive")
	var headlight_view: TextureRect = composer.target_view("headlight")
	_expect(headlight_view != null and headlight_view.size == Vector2(157.0, 45.0), "runtime composer instantiates the calibrated headlight production overlay")
	_expect(headlight_view.z_index < composer.layer_view("vehicle_glass_rain").z_index, "headlight production overlay renders below the vehicle rain texture")
	_expect(composer.set_target_state("headlight", "blink"), "runtime composer switches the headlight to its restrained blink production state")
	_expect(composer.target_asset_path("headlight").ends_with("prop_vehicle_headlights_blink_v001.png"), "runtime composer records the active headlight state asset")
	_expect(composer.set_target_state("plate", "mouth_hint"), "runtime composer switches the plate to its mouth-hint production state")
	_expect(composer.target_asset_path("plate").ends_with("prop_vehicle_plate_mouth_hint_v001.png"), "runtime composer records the active plate state asset")
	_expect(composer.set_layer_state("adult_commuter_down", "look_up"), "runtime composer switches the adult to its confirmed look-up state")
	_expect(composer.layer_asset_path("adult_commuter_down").ends_with("char_adult_commuter_seated_look_up_v001.png"), "runtime composer records the active state asset")
	_expect(composer.set_layer_state("adult_commuter_down", "missing"), "unknown adult state falls back to its confirmed default asset")
	_expect(composer.layer_asset_path("adult_commuter_down").ends_with("char_adult_commuter_seated_down_v001.png"), "runtime composer records the default asset after state fallback")
	var child_view: TextureRect = composer.layer_view("child_reflection")
	_expect(child_view != null, "runtime composer instantiates the independent child reflection")
	_expect(is_equal_approx(child_view.modulate.a, 0.0), "child reflection starts hidden")
	_expect(child_view.material is ShaderMaterial, "child reflection receives its glass mask and reflection treatment")
	_expect(composer.set_layer_state("child_reflection", "faint"), "runtime switches the child to the second-observation reflection state")
	_expect(is_equal_approx(child_view.modulate.a, 0.11), "second-observation child reflection is very faint")
	_expect(composer.set_layer_state("child_reflection", "visible"), "runtime switches the child to the third-observation reflection state")
	_expect(is_equal_approx(child_view.modulate.a, 0.22), "third-observation child reflection keeps the confirmed visual strength")
	var warm_view: TextureRect = composer.layer_view("window_reflection_warm")
	_expect(warm_view != null, "runtime composer instantiates the independent local warm reflection")
	_expect(is_equal_approx(warm_view.modulate.a, 0.0), "local warm reflection starts hidden")
	_expect(warm_view.stretch_mode == TextureRect.STRETCH_SCALE, "runtime preserves the approved warm-reflection review rectangle")
	_expect(warm_view.material is ShaderMaterial, "local warm reflection receives its screen blend and glass mask")
	_expect(composer.set_layer_state("window_reflection_warm", "visible"), "runtime switches warmth on only for the third observation")
	_expect(is_equal_approx(warm_view.modulate.a, 0.14), "third-observation warmth keeps the approved visual strength")
	_expect(composer.apply_interaction_state({"sequence_index": 1}), "runtime accepts the first commute observation state")
	_expect(composer.layer_asset_path("adult_commuter_down").ends_with("char_adult_commuter_seated_down_v001.png"), "first observation keeps the adult looking down")
	_expect(is_equal_approx(child_view.modulate.a, 0.0) and is_equal_approx(warm_view.modulate.a, 0.0), "first observation hides both reflection layers")
	_expect(composer.apply_interaction_state({"sequence_index": 2}), "runtime accepts the second commute observation state")
	_expect(composer.layer_asset_path("adult_commuter_down").ends_with("char_adult_commuter_seated_look_up_v001.png"), "second observation raises the adult's gaze")
	_expect(is_equal_approx(child_view.modulate.a, 0.11) and is_equal_approx(warm_view.modulate.a, 0.0), "second observation shows only the faint child reflection")
	_expect(composer.apply_interaction_state({"sequence_index": 3}), "runtime accepts the third commute observation state")
	_expect(is_equal_approx(child_view.modulate.a, 0.22) and is_equal_approx(warm_view.modulate.a, 0.14), "third observation reaches the confirmed child and warmth strengths")
	_expect(composer.target_asset_path("headlight").ends_with("prop_vehicle_headlights_blink_v001.png") and composer.target_asset_path("plate").ends_with("prop_vehicle_plate_mouth_hint_v001.png"), "third observation activates both restrained vehicle hints")
	composer.queue_free()


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


func _test_repeat_observe_contract() -> void:
	var scene := Catalog.get_scene("c01_s02_commute_window")
	var model = ModelScript.new()
	model.configure(scene)
	var phone: Dictionary = model.dispatch("tap", "phone")
	_expect(phone["accepted"] and phone["feedback"] == "工作群。天气。外卖。", "phone is available before observing the window")
	var early_headlight: Dictionary = model.dispatch("tap", "headlight")
	_expect(not early_headlight["accepted"], "headlight stays locked before the second observation")
	var first: Dictionary = model.dispatch("tap", "window")
	_expect(first["feedback"] == "车窗。", "first window observation uses its authored feedback")
	var second: Dictionary = model.dispatch("tap", "window")
	_expect(second["feedback"] == "车窗上有一点你的影子。", "second window observation reveals the reflection in text")
	var headlight: Dictionary = model.dispatch("tap", "headlight")
	_expect(headlight["accepted"] and headlight["feedback"] == "两个亮点。像眼睛。", "headlight unlocks after the second observation")
	var plate: Dictionary = model.dispatch("tap", "plate")
	_expect(plate["accepted"] and plate["feedback"] == "像一张抿起来的嘴。", "plate uses its authored optional feedback")
	var third: Dictionary = model.dispatch("tap", "window")
	_expect(third["just_completed"] and third["feedback"] == "前面的车灯，好像在看这边。", "third observation completes with the authored entry feedback")
	_expect(third["sfx"] == "glass", "third observation requests the restrained glass cue before the completion reveal")


func _test_repeat_observe_board_unlocks() -> void:
	var board = BoardScript.new()
	board.size = Vector2(720.0, 1280.0)
	root.add_child(board)
	await process_frame
	board.configure(Catalog.get_scene("c01_s02_commute_window"), [], false)
	await process_frame
	var buttons: Dictionary = board.get("_buttons")
	_expect(buttons.has("phone") and buttons["phone"].visible, "phone hotspot is visible from scene start")
	_expect(buttons.has("headlight") and not buttons["headlight"].visible, "headlight hotspot starts hidden")
	_expect(buttons.has("plate") and not buttons["plate"].visible, "plate hotspot starts hidden")
	_expect(buttons["phone"].get("_presentation_mode") == "region", "migrated phone hotspot does not redraw its legacy atlas visual")
	board.submit_action("tap", "window")
	_expect(not buttons["headlight"].visible, "headlight remains hidden after one observation")
	board.submit_action("tap", "window")
	_expect(buttons["headlight"].visible and not buttons["headlight"].disabled, "headlight becomes interactive after two observations")
	_expect(buttons["plate"].visible and not buttons["plate"].disabled, "plate becomes interactive after two observations")
	_expect(buttons["headlight"].get("_presentation_mode") == "region" and buttons["plate"].get("_presentation_mode") == "region", "migrated vehicle hotspots do not redraw legacy atlas visuals")
	board.queue_free()
	await process_frame


func _test_board_renders_every_scene() -> void:
	var board = BoardScript.new()
	board.size = Vector2(680.0, 500.0)
	root.add_child(board)
	await process_frame
	for scene_id in Catalog.get_scene_ids():
		board.configure(Catalog.get_scene(scene_id), ["candy_badge"])
		await process_frame
		_expect(board.get_node_or_null("BoardShell") != null, "%s renders one reusable board shell" % scene_id)
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
