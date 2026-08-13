extends SceneTree

const PREVIEW_ROOT := "res://assets/art/style-studies/c01_s02/previews/"
const WIDTH := 941
const HEIGHT := 1672
const EXPECTED_MASTER_SHA256 := "56821c1ff82eebcab880a931ec568532d25d3fc4dfb6f87e2353dc08223a47b6"
const WARM_EFFECT := "res://assets/art/style-studies/c01_s02/effects/fx_c01_s02_window_reflection_warm_v002_candidate.png"
const WARM_RECT := Rect2i(555, 710, 180, 333)
const WARM_STRENGTH := 0.14
const GLASS_POLYGON := [Vector2(374, 8), Vector2(933, 8), Vector2(933, 1380), Vector2(367, 1014)]

const SOURCES := {
	"master": PREVIEW_ROOT + "preview_c01_s02_vehicle_focus_context_look_up_v005.png",
	"neutral": PREVIEW_ROOT + "preview_c01_s02_vehicle_states_neutral_v001.png",
	"hint": PREVIEW_ROOT + "preview_c01_s02_vehicle_states_hint_v001.png",
	"child_visible": PREVIEW_ROOT + "preview_c01_s02_child_reflection_v001.png",
	"adult_down": PREVIEW_ROOT + "preview_c01_s02_phone_cold_adult_down_v001.png",
	"adult_up": PREVIEW_ROOT + "preview_c01_s02_phone_cold_adult_look_up_v001.png",
}

const OUTPUTS := {
	"state_01": PREVIEW_ROOT + "preview_c01_s02_observation_state_01_locked_v002.png",
	"state_02": PREVIEW_ROOT + "preview_c01_s02_observation_state_02_faint_v002.png",
	"state_03": PREVIEW_ROOT + "preview_c01_s02_observation_state_03_visible_v002.png",
	"strip": PREVIEW_ROOT + "preview_c01_s02_observation_states_v002.png",
	"state_03_warm": PREVIEW_ROOT + "preview_c01_s02_observation_state_03_warm_v002_candidate.png",
	"warm_comparison": PREVIEW_ROOT + "preview_c01_s02_observation_state_03_warm_comparison_v002.png",
}


func _initialize() -> void:
	var error := _build()
	quit(0 if error.is_empty() else 1)


func _build() -> String:
	if FileAccess.get_sha256(SOURCES["master"]) != EXPECTED_MASTER_SHA256:
		return _fail("approved v005 full-scene master hash changed")

	var images: Dictionary = {}
	for source_name in SOURCES:
		var image := Image.new()
		var load_error := image.load(ProjectSettings.globalize_path(SOURCES[source_name]))
		if load_error != OK or image.is_empty():
			return _fail("could not load %s" % SOURCES[source_name])
		if image.get_size() != Vector2i(WIDTH, HEIGHT):
			return _fail("%s has size %s; expected %s" % [
				SOURCES[source_name], image.get_size(), Vector2i(WIDTH, HEIGHT)
			])
		image.convert(Image.FORMAT_RGB8)
		images[source_name] = image

	var master_data: PackedByteArray = images["master"].get_data()
	var neutral_data: PackedByteArray = images["neutral"].get_data()
	var hint_data: PackedByteArray = images["hint"].get_data()
	var child_data: PackedByteArray = images["child_visible"].get_data()
	var adult_down_data: PackedByteArray = images["adult_down"].get_data()
	var adult_up_data: PackedByteArray = images["adult_up"].get_data()

	var neutral_mask := _changed_mask(neutral_data, master_data)
	var hint_mask := _changed_mask(hint_data, neutral_data)
	var child_mask := _changed_mask(child_data, hint_data)
	var adult_mask := _changed_mask(adult_down_data, adult_up_data)

	var state_01 := _apply_delta(neutral_data, adult_down_data, adult_up_data, 1.0)
	var state_02 := _apply_delta(neutral_data, child_data, hint_data, 0.5)
	var state_03 := child_data.duplicate()

	var error := _assert_locked(
		"state_01", state_01, master_data, [neutral_mask, adult_mask]
	)
	if not error.is_empty():
		return error
	error = _assert_locked("state_02", state_02, master_data, [neutral_mask, child_mask])
	if not error.is_empty():
		return error
	error = _assert_locked(
		"state_03", state_03, master_data, [neutral_mask, hint_mask, child_mask]
	)
	if not error.is_empty():
		return error

	var states := [state_01, state_02, state_03]
	for index in states.size():
		var output_name: String = ["state_01", "state_02", "state_03"][index]
		var output := Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGB8, states[index])
		if output.save_png(OUTPUTS[output_name]) != OK:
			return _fail("could not write %s" % OUTPUTS[output_name])

	var strip := Image.create(1080, 640, false, Image.FORMAT_RGB8)
	for index in states.size():
		var panel := Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGB8, states[index])
		panel.resize(360, 640, Image.INTERPOLATE_LANCZOS)
		strip.blit_rect(panel, Rect2i(0, 0, 360, 640), Vector2i(index * 360, 0))
	if strip.save_png(OUTPUTS["strip"]) != OK:
		return _fail("could not write %s" % OUTPUTS["strip"])

	var warm_effect := Image.new()
	var warm_load_error := warm_effect.load(ProjectSettings.globalize_path(WARM_EFFECT))
	if warm_load_error != OK or warm_effect.is_empty():
		return _fail("could not load %s" % WARM_EFFECT)
	warm_effect.convert(Image.FORMAT_RGBA8)
	warm_effect.resize(WARM_RECT.size.x, WARM_RECT.size.y, Image.INTERPOLATE_LANCZOS)
	var warm_result := _apply_warm_screen(state_03, warm_effect.get_data())
	var warm_state: PackedByteArray = warm_result["pixels"]
	var warm_mask: PackedByteArray = warm_result["mask"]
	error = _assert_locked("state_03_warm", warm_state, state_03, [warm_mask])
	if not error.is_empty():
		return error
	var warm_output := Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGB8, warm_state)
	if warm_output.save_png(OUTPUTS["state_03_warm"]) != OK:
		return _fail("could not write %s" % OUTPUTS["state_03_warm"])
	var warm_comparison := Image.create(720, 640, false, Image.FORMAT_RGB8)
	for index in 2:
		var panel_data: PackedByteArray = state_03 if index == 0 else warm_state
		var panel := Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGB8, panel_data)
		panel.resize(360, 640, Image.INTERPOLATE_LANCZOS)
		warm_comparison.blit_rect(panel, Rect2i(0, 0, 360, 640), Vector2i(index * 360, 0))
	if warm_comparison.save_png(OUTPUTS["warm_comparison"]) != OK:
		return _fail("could not write %s" % OUTPUTS["warm_comparison"])

	print("authorized masks:")
	print("  adult state: %d pixels" % _mask_count(adult_mask))
	print("  neutral vehicle overlays: %d pixels" % _mask_count(neutral_mask))
	print("  vehicle hint: %d pixels" % _mask_count(hint_mask))
	print("  child reflection: %d pixels" % _mask_count(child_mask))
	print("  local warm reflection: %d pixels" % _mask_count(warm_mask))
	for output_name in OUTPUTS:
		print("%s: %s sha256=%s" % [
			output_name, OUTPUTS[output_name], FileAccess.get_sha256(OUTPUTS[output_name])
		])
	return ""


func _changed_mask(left: PackedByteArray, right: PackedByteArray) -> PackedByteArray:
	var mask := PackedByteArray()
	mask.resize(WIDTH * HEIGHT)
	for pixel_index in mask.size():
		var byte_index := pixel_index * 3
		mask[pixel_index] = int(
			left[byte_index] != right[byte_index]
			or left[byte_index + 1] != right[byte_index + 1]
			or left[byte_index + 2] != right[byte_index + 2]
		)
	return mask


func _apply_delta(
	base: PackedByteArray,
	source: PackedByteArray,
	reference: PackedByteArray,
	scale: float
) -> PackedByteArray:
	var output := base.duplicate()
	for byte_index in output.size():
		output[byte_index] = clampi(
			roundi(base[byte_index] + (source[byte_index] - reference[byte_index]) * scale),
			0,
			255
		)
	return output


func _apply_warm_screen(base: PackedByteArray, effect: PackedByteArray) -> Dictionary:
	var output := base.duplicate()
	var mask := PackedByteArray()
	mask.resize(WIDTH * HEIGHT)
	var glass_polygon := PackedVector2Array(GLASS_POLYGON)
	for local_y in WARM_RECT.size.y:
		for local_x in WARM_RECT.size.x:
			var point := Vector2i(WARM_RECT.position.x + local_x, WARM_RECT.position.y + local_y)
			if not Geometry2D.is_point_in_polygon(Vector2(point) + Vector2(0.5, 0.5), glass_polygon):
				continue
			var effect_byte := (local_y * WARM_RECT.size.x + local_x) * 4
			var alpha := effect[effect_byte + 3] / 255.0 * WARM_STRENGTH
			if alpha <= 0.0:
				continue
			var pixel_index := point.y * WIDTH + point.x
			var base_byte := pixel_index * 3
			for channel in 3:
				var base_value: float = base[base_byte + channel]
				var effect_value: float = effect[effect_byte + channel]
				var screen_value := 255.0 - (255.0 - base_value) * (255.0 - effect_value) / 255.0
				output[base_byte + channel] = clampi(
					roundi(base_value * (1.0 - alpha) + screen_value * alpha), 0, 255
				)
			mask[pixel_index] = 1
	return {"pixels": output, "mask": mask}


func _assert_locked(
	state_name: String,
	output: PackedByteArray,
	master: PackedByteArray,
	authorized_masks: Array
) -> String:
	var drift_count := 0
	var min_point := Vector2i(WIDTH, HEIGHT)
	var max_point := Vector2i(-1, -1)
	for pixel_index in WIDTH * HEIGHT:
		var authorized := false
		for mask in authorized_masks:
			if mask[pixel_index] != 0:
				authorized = true
				break
		if authorized:
			continue
		var byte_index := pixel_index * 3
		if (
			output[byte_index] == master[byte_index]
			and output[byte_index + 1] == master[byte_index + 1]
			and output[byte_index + 2] == master[byte_index + 2]
		):
			continue
		drift_count += 1
		var point := Vector2i(pixel_index % WIDTH, pixel_index / WIDTH)
		min_point = min_point.min(point)
		max_point = max_point.max(point)

	if drift_count > 0:
		return _fail("%s: %d pixels changed outside authorized masks; bbox=%s..%s" % [
			state_name, drift_count, min_point, max_point + Vector2i.ONE
		])
	print("%s: immutable pixels passed, outside-authorized drift = 0" % state_name)
	return ""


func _mask_count(mask: PackedByteArray) -> int:
	var count := 0
	for value in mask:
		count += int(value != 0)
	return count


func _fail(message: String) -> String:
	push_error(message)
	return message
