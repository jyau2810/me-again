extends SceneTree

## Captures the approved commute scene through the real InteractionBoard and
## SceneVisualComposer state chain. Requires a non-headless renderer.

const Catalog = preload("res://scripts/content/story_content_catalog.gd")
const BoardScript = preload("res://scripts/interactions/interaction_board.gd")
const LayoutStore = preload("res://scripts/interactions/interaction_scene_layout_store.gd")
const VisualComposerScript = preload("res://scripts/interactions/scene_visual_composer.gd")

const SCENE_ID := "c01_s02_commute_window"
const CANVAS_SIZE := Vector2i(720, 1280)
const OUTPUT_ROOT := "res://assets/art/style-studies/c01_s02/previews/"
const OUTPUTS := [
	OUTPUT_ROOT + "preview_c01_s02_runtime_observation_state_01_v001.png",
	OUTPUT_ROOT + "preview_c01_s02_runtime_observation_state_02_v001.png",
	OUTPUT_ROOT + "preview_c01_s02_runtime_observation_state_03_v001.png",
]
const STRIP_OUTPUT := OUTPUT_ROOT + "preview_c01_s02_runtime_observation_states_v001.png"

var _viewport: SubViewport


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var error := await _capture()
	if error.is_empty():
		quit(0)
	else:
		push_error(error)
		quit(1)


func _capture() -> String:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	_viewport = SubViewport.new()
	_viewport.name = "RuntimeCaptureViewport"
	_viewport.size = CANVAS_SIZE
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	_viewport.transparent_bg = false
	root.add_child(_viewport)

	var stage := Control.new()
	stage.size = Vector2(CANVAS_SIZE)
	_viewport.add_child(stage)
	var background := TextureRect.new()
	background.size = Vector2(CANVAS_SIZE)
	background.texture = load(LayoutStore.reference_background_path(SCENE_ID)) as Texture2D
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(background)

	var scene_visuals = VisualComposerScript.new()
	scene_visuals.size = Vector2(CANVAS_SIZE)
	scene_visuals.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(scene_visuals)
	scene_visuals.configure(SCENE_ID, true)
	var shade := ColorRect.new()
	shade.size = Vector2(CANVAS_SIZE)
	shade.color = VisualComposerScript.ENTRY_TINT
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.z_index = 50
	stage.add_child(shade)

	var board = BoardScript.new()
	board.size = Vector2(CANVAS_SIZE)
	board.visible = false
	root.add_child(board)
	await _settle(3)
	board.interaction_state_changed.connect(scene_visuals.apply_interaction_state)
	board.configure(Catalog.get_scene(SCENE_ID), [], false)
	await _settle(3)
	if shade.color != Color("#0d17204a"):
		return "entry scene tint drifted from #0d17204a"

	var images: Array[Image] = []
	var results: Array[Dictionary] = []
	for index in 3:
		var result: Dictionary = board.submit_action("tap", "window")
		results.append(result)
		await _settle(3)
		var image := _viewport.get_texture().get_image()
		if image.is_empty() or image.get_size() != CANVAS_SIZE:
			return "runtime state %d rendered an invalid frame" % (index + 1)
		image.convert(Image.FORMAT_RGBA8)
		if image.save_png(OUTPUTS[index]) != OK:
			return "could not write %s" % OUTPUTS[index]
		images.append(image)

	var expected_feedback := [
		"车窗。",
		"车窗上有一点你的影子。",
		"前面的车灯，好像在看这边。",
	]
	for index in results.size():
		if String(results[index].get("feedback", "")) != expected_feedback[index]:
			return "runtime observation %d returned the wrong feedback" % (index + 1)

	var first_diff := _difference_count(images[0], images[1])
	var second_diff := _difference_count(images[1], images[2])
	if first_diff < 1000 or second_diff < 1000:
		return "runtime observation states are not visually distinct"

	var child_view: TextureRect = scene_visuals.call("layer_view", "child_reflection")
	var warm_view: TextureRect = scene_visuals.call("layer_view", "window_reflection_warm")
	if child_view == null or warm_view == null:
		return "runtime reflection layers are missing"
	if not is_equal_approx(child_view.modulate.a, 0.22) or not is_equal_approx(warm_view.modulate.a, 0.14):
		return "third observation did not reach the approved reflection strengths"

	# Rebuild the second state and remove only the child to verify that the
	# reflection shader never leaks beyond the authored glass boundary.
	scene_visuals.apply_interaction_state({"sequence_index": 2})
	await _settle(3)
	scene_visuals.set_layer_state("child_reflection", "hidden")
	await _settle(3)
	var second_without_child := _viewport.get_texture().get_image()
	second_without_child.convert(Image.FORMAT_RGBA8)
	var clip_error := _assert_difference_inside_glass(
		second_without_child, images[1], "child reflection"
	)
	if not clip_error.is_empty():
		return clip_error

	# Re-render only the warm layer off to prove that the screen blend remains
	# strictly inside the authored glass polygon in the production renderer.
	scene_visuals.apply_interaction_state({"sequence_index": 3})
	await _settle(3)
	scene_visuals.set_layer_state("window_reflection_warm", "hidden")
	await _settle(3)
	var third_without_warm := _viewport.get_texture().get_image()
	third_without_warm.convert(Image.FORMAT_RGBA8)
	clip_error = _assert_difference_inside_glass(
		third_without_warm, images[2], "local warmth"
	)
	if not clip_error.is_empty():
		return clip_error
	scene_visuals.set_layer_state("window_reflection_warm", "visible")

	var strip := Image.create(1080, 640, false, Image.FORMAT_RGBA8)
	for index in images.size():
		var panel := images[index].duplicate()
		panel.resize(360, 640, Image.INTERPOLATE_LANCZOS)
		strip.blit_rect(panel, Rect2i(0, 0, 360, 640), Vector2i(index * 360, 0))
	if strip.save_png(STRIP_OUTPUT) != OK:
		return "could not write %s" % STRIP_OUTPUT

	print("runtime observation captures:")
	for index in OUTPUTS.size():
		print("  state %d: %s sha256=%s" % [
			index + 1, OUTPUTS[index], FileAccess.get_sha256(OUTPUTS[index])
		])
	print("  strip: %s sha256=%s" % [STRIP_OUTPUT, FileAccess.get_sha256(STRIP_OUTPUT)])
	print("  state 1 -> 2 changed pixels: %d" % first_diff)
	print("  state 2 -> 3 changed pixels: %d" % second_diff)
	return ""


func _settle(frame_count: int) -> void:
	for _index in frame_count:
		await process_frame
		RenderingServer.force_draw(false)


func _difference_count(left: Image, right: Image) -> int:
	var count := 0
	for y in CANVAS_SIZE.y:
		for x in CANVAS_SIZE.x:
			if left.get_pixel(x, y) != right.get_pixel(x, y):
				count += 1
	return count


func _assert_difference_inside_glass(without_layer: Image, with_layer: Image, label: String) -> String:
	var layer := LayoutStore.layer(SCENE_ID, "window_reflection_warm")
	var polygon := PackedVector2Array(layer.get("clip_polygon", []))
	if polygon.size() != 4:
		return "warm reflection is missing its four-point glass clip"
	var changed := 0
	var outside := 0
	for y in CANVAS_SIZE.y:
		for x in CANVAS_SIZE.x:
			if without_layer.get_pixel(x, y) == with_layer.get_pixel(x, y):
				continue
			changed += 1
			if not _pixel_touches_polygon(x, y, polygon):
				outside += 1
	if changed == 0:
		return "%s rendered no changed pixels" % label
	if outside > 0:
		return "%s changed %d pixels outside the glass" % [label, outside]
	print("  %s changed pixels: %d; outside glass: 0" % [label, changed])
	return ""


func _pixel_touches_polygon(x: int, y: int, polygon: PackedVector2Array) -> bool:
	# The renderer shades whole edge pixels whose square intersects the hard clip.
	# Test the center and four corners so the guard follows that raster boundary.
	for offset in [
		Vector2(0.5, 0.5),
		Vector2.ZERO,
		Vector2(1.0, 0.0),
		Vector2(1.0, 1.0),
		Vector2(0.0, 1.0),
	]:
		if Geometry2D.is_point_in_polygon(Vector2(x, y) + offset, polygon):
			return true
	return false
