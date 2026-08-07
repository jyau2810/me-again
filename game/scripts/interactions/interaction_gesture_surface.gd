class_name InteractionGestureSurface
extends Control

## Pointer canvas used by route, lap, tracing and real multi-touch interactions.
## All recognition is deliberately forgiving: an imprecise stroke produces a
## gentle retry signal and leaves the player exactly where they were.

signal route_resolved(data: Dictionary)
signal lap_detected(data: Dictionary)
signal trace_resolved(line_id: String, data: Dictionary)
signal multi_gesture(action: String, data: Dictionary)
signal surface_feedback(text: String, tone: String)

const MODE_ROUTE := "route"
const MODE_LOOP := "loop"
const MODE_TRACE := "trace"
const MODE_MULTI := "multi"

const COLOR_BG := Color(0.0, 0.0, 0.0, 0.0)
const COLOR_GUIDE := Color("71877f")
const COLOR_ACTIVE := Color("e4c98b")
const COLOR_SAFE := Color("8bc9ad")
const COLOR_DANGER := Color("a56f6b")
const COLOR_INK := Color("f2dfab")

var mode := ""
var _active := false
var _using_mouse := false
var _pointer_id := -1
var _stroke: PackedVector2Array = []
var _stroke_started_msec := 0

var _route_hit_blocker := false
var _route_on_track_samples := 0
var _route_sample_count := 0

var _loop_angle_total := 0.0
var _loop_last_angle := 0.0
var _lap_started_msec := 0
var _loop_on_track_samples := 0
var _loop_sample_count := 0

var _trace_ids: Array[String] = []
var _trace_index := 0
var _trace_tolerance := 44.0

var _multi_order: Array[String] = []
var _multi_index := 0
var _touches: Dictionary = {}
var _touch_starts: Dictionary = {}
var _touch_started_msec: Dictionary = {}
var _two_start_distance := 0.0
var _two_start_centroid := Vector2.ZERO
var _two_started_msec := 0
var _multi_emitted := false
var _ripple_position := Vector2.ZERO
var _ripple_amount := 1.0


func _ready() -> void:
	custom_minimum_size = Vector2(540.0, 250.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	resized.connect(queue_redraw)
	set_process(false)


func configure_route() -> void:
	_reset_surface(MODE_ROUTE)


func configure_loop() -> void:
	_reset_surface(MODE_LOOP)


func configure_trace(ids: Array[String], wide_tolerance := true) -> void:
	_reset_surface(MODE_TRACE)
	_trace_ids = ids.duplicate()
	_trace_index = 0
	_trace_tolerance = 50.0 if wide_tolerance else 36.0
	queue_redraw()


func configure_multi(required_order: Array[String], start_index := 0) -> void:
	_reset_surface(MODE_MULTI)
	_multi_order = required_order.duplicate()
	_multi_index = clampi(start_index, 0, maxi(0, _multi_order.size() - 1))
	set_process(true)
	queue_redraw()


func set_multi_step(index: int) -> void:
	_multi_index = clampi(index, 0, maxi(0, _multi_order.size() - 1))
	_multi_emitted = false
	_rebase_two_touch()
	queue_redraw()


func current_trace_id() -> String:
	if _trace_index < 0 or _trace_index >= _trace_ids.size():
		return ""
	return _trace_ids[_trace_index]


func advance_trace() -> void:
	_trace_index = mini(_trace_index + 1, _trace_ids.size())
	_stroke = PackedVector2Array()
	queue_redraw()


func _reset_surface(next_mode: String) -> void:
	mode = next_mode
	_active = false
	_using_mouse = false
	_pointer_id = -1
	_stroke = PackedVector2Array()
	_route_hit_blocker = false
	_loop_angle_total = 0.0
	_touches.clear()
	_touch_starts.clear()
	_touch_started_msec.clear()
	_multi_emitted = false
	set_process(next_mode == MODE_MULTI)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if event.pressed:
			_begin_pointer(event.position, -1, true)
		else:
			_end_pointer(event.position, -1, true)
		return
	if event is InputEventMouseMotion and _using_mouse and _active:
		accept_event()
		_move_pointer(event.position, -1, true)
		return
	if event is InputEventScreenTouch:
		accept_event()
		# Viewport converts ScreenTouch positions into the receiving Control's
		# local coordinates before `_gui_input` is called.
		var local_position: Vector2 = event.position
		if event.pressed:
			_begin_touch(event.index, local_position)
		else:
			_end_touch(event.index, local_position)
		return
	if event is InputEventScreenDrag:
		accept_event()
		var local_position: Vector2 = event.position
		_move_touch(event.index, local_position)


func _process(_delta: float) -> void:
	if mode != MODE_MULTI or _multi_emitted:
		return
	var expected := _current_multi_action()
	if expected not in ["hold_two_fingers", "hold"]:
		return
	var needed_msec := 800
	if _touches.size() >= 2 and Time.get_ticks_msec() - _two_started_msec >= needed_msec:
		_emit_multi(expected, {"seconds": float(Time.get_ticks_msec() - _two_started_msec) / 1000.0})
	elif _using_mouse and Input.is_key_pressed(KEY_SHIFT):
		if Time.get_ticks_msec() - _stroke_started_msec >= needed_msec:
			_emit_multi(expected, {
				"seconds": float(Time.get_ticks_msec() - _stroke_started_msec) / 1000.0,
				"fallback": "shift_mouse",
			})


func _begin_pointer(position: Vector2, pointer_id: int, is_mouse: bool) -> void:
	_start_ripple(position)
	if mode == MODE_MULTI:
		_active = true
		_using_mouse = is_mouse
		_pointer_id = pointer_id
		_stroke = PackedVector2Array([position])
		_stroke_started_msec = Time.get_ticks_msec()
		_multi_emitted = false
		queue_redraw()
		return

	if _active:
		return
	if mode == MODE_ROUTE and not _route_start_rect().grow(24.0).has_point(position):
		surface_feedback.emit("左侧的安全带扣亮着，暗路从那里伸出去。", "gentle")
		return
	if mode == MODE_LOOP and not _point_near_loop(position, 72.0):
		surface_feedback.emit("墙边的圆线还没亮，起点仍停在那里。", "gentle")
		return

	_active = true
	_using_mouse = is_mouse
	_pointer_id = pointer_id
	_stroke = PackedVector2Array([position])
	_stroke_started_msec = Time.get_ticks_msec()
	if mode == MODE_ROUTE:
		_route_hit_blocker = false
		_route_on_track_samples = 0
		_route_sample_count = 0
	elif mode == MODE_LOOP:
		_loop_angle_total = 0.0
		_loop_last_angle = (position - _loop_center()).angle()
		_lap_started_msec = Time.get_ticks_msec()
		_loop_on_track_samples = 0
		_loop_sample_count = 0
	queue_redraw()


func _move_pointer(position: Vector2, pointer_id: int, is_mouse: bool) -> void:
	if not _active or _pointer_id != pointer_id or _using_mouse != is_mouse:
		return
	var previous := _stroke[-1] if not _stroke.is_empty() else position
	_stroke.append(position)
	match mode:
		MODE_ROUTE:
			_update_route(previous, position)
		MODE_LOOP:
			_update_loop(position)
		MODE_MULTI:
			_update_mouse_multi(position)
	queue_redraw()


func _end_pointer(position: Vector2, pointer_id: int, is_mouse: bool) -> void:
	if not _active or _pointer_id != pointer_id or _using_mouse != is_mouse:
		return
	if _stroke.is_empty() or _stroke[-1] != position:
		_move_pointer(position, pointer_id, is_mouse)
	match mode:
		MODE_ROUTE:
			_finish_route(position)
		MODE_TRACE:
			_finish_trace()
		MODE_LOOP:
			if absf(_loop_angle_total) < TAU * 0.7:
				surface_feedback.emit("这一圈断开了，起点仍在墙边发亮。", "gentle")
		MODE_MULTI:
			_finish_mouse_multi(position)
	_active = false
	_using_mouse = false
	_pointer_id = -1
	queue_redraw()


func _begin_touch(index: int, position: Vector2) -> void:
	_start_ripple(position)
	if mode != MODE_MULTI:
		_begin_pointer(position, index, false)
		return
	_touches[index] = position
	_touch_starts[index] = position
	_touch_started_msec[index] = Time.get_ticks_msec()
	if _touches.size() == 2:
		_rebase_two_touch()
	_multi_emitted = false
	queue_redraw()


func _move_touch(index: int, position: Vector2) -> void:
	if mode != MODE_MULTI:
		_move_pointer(position, index, false)
		return
	if not _touches.has(index):
		return
	_touches[index] = position
	var expected := _current_multi_action()
	if _multi_emitted:
		queue_redraw()
		return
	if expected == "drag_branch":
		var start: Vector2 = _touch_starts.get(index, position)
		if position.distance_to(start) >= 68.0:
			_emit_multi(expected, {"distance": position.distance_to(start), "touch_points": 1})
	elif _touches.size() >= 2:
		var pair := _first_two_touch_positions()
		var distance: float = pair[0].distance_to(pair[1])
		var centroid: Vector2 = (pair[0] + pair[1]) * 0.5
		if expected == "separate" and distance - _two_start_distance >= 48.0:
			_emit_multi(expected, {"distance_delta": distance - _two_start_distance, "touch_points": 2})
		elif expected == "lift" and _two_start_centroid.y - centroid.y >= 42.0:
			_emit_multi(expected, {"lift_distance": _two_start_centroid.y - centroid.y, "touch_points": 2})
	queue_redraw()


func _end_touch(index: int, position: Vector2) -> void:
	if mode != MODE_MULTI:
		_end_pointer(position, index, false)
		return
	if _touches.has(index) and not _multi_emitted and _current_multi_action() == "tap_shadow":
		var start: Vector2 = _touch_starts.get(index, position)
		var started := int(_touch_started_msec.get(index, Time.get_ticks_msec()))
		if start.distance_to(position) <= 24.0 and Time.get_ticks_msec() - started <= 700:
			_emit_multi("tap_shadow", {"touch_points": 1})
	_touches.erase(index)
	_touch_starts.erase(index)
	_touch_started_msec.erase(index)
	if _touches.size() < 2:
		_two_started_msec = 0
	queue_redraw()


func _update_route(previous: Vector2, position: Vector2) -> void:
	_route_sample_count += 1
	if _route_safe_corridor().has_point(position):
		_route_on_track_samples += 1
	for blocker in _route_blockers():
		var padded := blocker.grow(5.0)
		if (
			padded.has_point(position)
			or padded.has_point(previous)
			or padded.has_point((previous + position) * 0.5)
		):
			_route_hit_blocker = true


func _finish_route(position: Vector2) -> void:
	var at_finish := _route_finish_rect().grow(18.0).has_point(position)
	var ratio := (
		float(_route_on_track_samples) / float(_route_sample_count)
		if _route_sample_count > 0
		else 0.0
	)
	route_resolved.emit({
		"success": at_finish and not _route_hit_blocker,
		"hit_blocker": _route_hit_blocker,
		"accuracy": clampf(ratio, 0.0, 1.0),
	})


func _update_loop(position: Vector2) -> void:
	var current_angle := (position - _loop_center()).angle()
	var delta := wrapf(current_angle - _loop_last_angle, -PI, PI)
	_loop_last_angle = current_angle
	if absf(delta) > 0.65:
		return
	_loop_angle_total += delta
	_loop_sample_count += 1
	if _point_near_loop(position, 52.0):
		_loop_on_track_samples += 1
	if absf(_loop_angle_total) >= TAU * 0.92:
		var now := Time.get_ticks_msec()
		var ratio := (
			float(_loop_on_track_samples) / float(_loop_sample_count)
			if _loop_sample_count > 0
			else 0.0
		)
		lap_detected.emit({
			"duration": float(now - _lap_started_msec) / 1000.0,
			"on_track_ratio": clampf(ratio, 0.0, 1.0),
		})
		_loop_angle_total = fmod(_loop_angle_total, TAU * 0.92)
		_lap_started_msec = now
		_loop_on_track_samples = 0
		_loop_sample_count = 0


func _finish_trace() -> void:
	var line_id := current_trace_id()
	var guide := _trace_guide(line_id)
	if line_id.is_empty() or guide.size() < 2 or _stroke.size() < 3:
		trace_resolved.emit(line_id, {"success": false, "accuracy": 0.0})
		return
	var near_count := 0
	var distance_total := 0.0
	for sample in _stroke:
		var distance := _distance_to_polyline(sample, guide)
		distance_total += distance
		if distance <= _trace_tolerance:
			near_count += 1
	var ratio := float(near_count) / float(_stroke.size())
	var average_distance := distance_total / float(_stroke.size())
	var forward := (
		_stroke[0].distance_to(guide[0]) <= _trace_tolerance * 1.5
		and _stroke[-1].distance_to(guide[-1]) <= _trace_tolerance * 1.5
	)
	var reverse := (
		_stroke[-1].distance_to(guide[0]) <= _trace_tolerance * 1.5
		and _stroke[0].distance_to(guide[-1]) <= _trace_tolerance * 1.5
	)
	trace_resolved.emit(line_id, {
		"success": (forward or reverse) and ratio >= 0.48,
		"accuracy": clampf(1.0 - average_distance / (_trace_tolerance * 1.7), 0.0, 1.0),
		"on_guide_ratio": ratio,
	})


func _update_mouse_multi(position: Vector2) -> void:
	if _multi_emitted or _stroke.is_empty():
		return
	var expected := _current_multi_action()
	if expected == "drag_branch" and position.distance_to(_stroke[0]) >= 68.0:
		_emit_multi(expected, {"distance": position.distance_to(_stroke[0]), "fallback": "mouse"})


func _finish_mouse_multi(position: Vector2) -> void:
	if _multi_emitted or _stroke.is_empty():
		return
	var expected := _current_multi_action()
	if expected == "tap_shadow" and position.distance_to(_stroke[0]) <= 24.0:
		_emit_multi(expected, {"fallback": "mouse"})


func _emit_multi(action: String, data: Dictionary) -> void:
	if _multi_emitted:
		return
	_multi_emitted = true
	multi_gesture.emit(action, data)
	queue_redraw()


func _start_ripple(position: Vector2) -> void:
	_ripple_position = position
	_ripple_amount = 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(func(value: float) -> void:
		_ripple_amount = value
		queue_redraw()
	, 0.0, 1.0, 0.24)


func _rebase_two_touch() -> void:
	if _touches.size() < 2:
		return
	var pair := _first_two_touch_positions()
	_two_start_distance = pair[0].distance_to(pair[1])
	_two_start_centroid = (pair[0] + pair[1]) * 0.5
	_two_started_msec = Time.get_ticks_msec()
	_multi_emitted = false


func _first_two_touch_positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for key in _touches.keys():
		result.append(_touches[key])
		if result.size() == 2:
			break
	return result


func _current_multi_action() -> String:
	if _multi_index < 0 or _multi_index >= _multi_order.size():
		return ""
	return _multi_order[_multi_index]


func _draw() -> void:
	var bounds := Rect2(Vector2.ZERO, _surface_size())
	draw_rect(bounds, COLOR_BG, true)
	match mode:
		MODE_ROUTE:
			_draw_route()
		MODE_LOOP:
			_draw_loop()
		MODE_TRACE:
			_draw_trace()
		MODE_MULTI:
			_draw_multi()
	if _ripple_amount < 1.0:
		draw_arc(
			_ripple_position,
			12.0 + 42.0 * _ripple_amount,
			0.0,
			TAU,
			36,
			Color(COLOR_ACTIVE, 0.82 * (1.0 - _ripple_amount)),
			2.6,
			true
		)


func _draw_route() -> void:
	draw_rect(_route_safe_corridor(), Color(0.3, 0.48, 0.43, 0.14), true)
	for blocker in _route_blockers():
		draw_rect(blocker, Color(0.62, 0.3, 0.3, 0.42), true)
		draw_rect(blocker, COLOR_DANGER, false, 2.0)
	draw_circle(_route_start_rect().get_center(), 18.0, COLOR_ACTIVE)
	draw_circle(_route_finish_rect().get_center(), 23.0, COLOR_SAFE, false, 5.0)
	_draw_label("起点", _route_start_rect().position + Vector2(-2.0, 58.0), COLOR_ACTIVE)
	_draw_label("安全出口", _route_finish_rect().position + Vector2(-18.0, 68.0), COLOR_SAFE)
	if _stroke.size() >= 2:
		draw_polyline(_stroke, COLOR_DANGER if _route_hit_blocker else COLOR_INK, 6.0, true)


func _draw_loop() -> void:
	var center := _loop_center()
	var radius := _loop_radius()
	draw_arc(center, radius, 0.0, TAU, 96, COLOR_GUIDE, 16.0, true)
	draw_arc(center, radius, 0.0, TAU, 96, COLOR_ACTIVE, 2.0, true)
	_draw_label("墙边的粉笔线", center + Vector2(-72.0, 5.0), Color("d8dfdc"))
	if _stroke.size() >= 2:
		draw_polyline(_stroke, COLOR_INK, 5.0, true)


func _draw_trace() -> void:
	var line_id := current_trace_id()
	if line_id.is_empty():
		_draw_label("三段旧线都留住了", _surface_size() * 0.5 - Vector2(80.0, 0.0), COLOR_SAFE)
		return
	var guide := _trace_guide(line_id)
	if guide.size() >= 2:
		draw_polyline(guide, Color(0.56, 0.63, 0.6, 0.45), 18.0, true)
		draw_polyline(guide, COLOR_ACTIVE, 3.0, true)
		draw_circle(guide[0], 10.0, COLOR_SAFE)
		draw_circle(guide[-1], 10.0, COLOR_SAFE, false, 3.0)
		_draw_label("线头", guide[0] + Vector2(-14.0, -20.0), COLOR_SAFE, 14)
	if _stroke.size() >= 2:
		draw_polyline(_stroke, COLOR_INK, 5.0, true)
	_draw_label("这道旧线：%s" % _trace_label(line_id), Vector2(18.0, 28.0), Color("d8dfdc"), 16)


func _draw_multi() -> void:
	var action := _current_multi_action()
	var center := _surface_size() * 0.5
	var text: String = String({
		"drag_branch": "交叠的枝叶",
		"tap_shadow": "醒来的树影",
		"hold_two_fingers": "靠在一起的两道手影",
		"separate": "分开的两道手影",
		"lift": "抬起木板的手影",
		"hold": "护住化石盒的手影",
	}.get(action, "双手动作完成"))
	_draw_label(text, center + Vector2(-92.0, -8.0), Color("e5e9e7"), 18)
	for position in _touches.values():
		draw_circle(position, 24.0, Color(0.91, 0.79, 0.53, 0.32), true)
		draw_circle(position, 24.0, COLOR_ACTIVE, false, 3.0)
	if _stroke.size() >= 2:
		draw_polyline(_stroke, Color(0.91, 0.79, 0.53, 0.72), 5.0, true)


func _route_start_rect() -> Rect2:
	var h := _surface_size().y
	return Rect2(Vector2(28.0, h * 0.67 - 24.0), Vector2(48.0, 48.0))


func _route_finish_rect() -> Rect2:
	var surface := _surface_size()
	return Rect2(Vector2(surface.x - 78.0, surface.y * 0.28 - 28.0), Vector2(56.0, 56.0))


func _route_safe_corridor() -> Rect2:
	var surface := _surface_size()
	return Rect2(Vector2(15.0, surface.y * 0.52), Vector2(surface.x - 30.0, surface.y * 0.35))


func _route_blockers() -> Array[Rect2]:
	var surface := _surface_size()
	return [
		Rect2(Vector2(surface.x * 0.31, surface.y * 0.44), Vector2(74.0, 90.0)),
		Rect2(Vector2(surface.x * 0.61, surface.y * 0.29), Vector2(82.0, 92.0)),
	]


func _loop_center() -> Vector2:
	return _surface_size() * 0.5


func _loop_radius() -> float:
	var surface := _surface_size()
	return minf(surface.x * 0.32, surface.y * 0.36)


func _point_near_loop(point: Vector2, tolerance: float) -> bool:
	return absf(point.distance_to(_loop_center()) - _loop_radius()) <= tolerance


func _trace_guide(line_id: String) -> PackedVector2Array:
	var surface := _surface_size()
	var left := 52.0
	var right := surface.x - 52.0
	var mid := surface.y * 0.55
	match line_id:
		"face":
			return PackedVector2Array([
				Vector2(left + 20.0, mid), Vector2(left + 75.0, mid - 65.0),
				Vector2(surface.x * 0.5, mid - 78.0), Vector2(right - 75.0, mid - 65.0),
				Vector2(right - 20.0, mid), Vector2(right - 80.0, mid + 62.0),
				Vector2(surface.x * 0.5, mid + 76.0), Vector2(left + 80.0, mid + 62.0),
				Vector2(left + 20.0, mid),
			])
		"hand":
			return PackedVector2Array([
				Vector2(left, mid + 45.0), Vector2(left + 90.0, mid - 5.0),
				Vector2(left + 165.0, mid - 52.0), Vector2(surface.x * 0.55, mid + 22.0),
				Vector2(right - 85.0, mid - 38.0), Vector2(right, mid + 8.0),
			])
		"bag":
			return PackedVector2Array([
				Vector2(left + 20.0, mid + 55.0), Vector2(left + 60.0, mid - 48.0),
				Vector2(surface.x * 0.5, mid - 76.0), Vector2(right - 60.0, mid - 48.0),
				Vector2(right - 20.0, mid + 55.0), Vector2(left + 20.0, mid + 55.0),
			])
		_:
			return PackedVector2Array([
				Vector2(left, mid + 42.0), Vector2(left + 80.0, mid - 16.0),
				Vector2(surface.x * 0.36, mid + 22.0), Vector2(surface.x * 0.5, mid - 48.0),
				Vector2(surface.x * 0.66, mid + 12.0), Vector2(right - 72.0, mid - 18.0),
				Vector2(right, mid + 35.0),
			])


func _distance_to_polyline(point: Vector2, line: PackedVector2Array) -> float:
	var nearest := INF
	for index in range(line.size() - 1):
		nearest = minf(nearest, _distance_to_segment(point, line[index], line[index + 1]))
	return nearest


func _distance_to_segment(point: Vector2, start: Vector2, finish: Vector2) -> float:
	var segment := finish - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.0001:
		return point.distance_to(start)
	var amount := clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(start + segment * amount)


func _surface_size() -> Vector2:
	return Vector2(maxf(size.x, 540.0), maxf(size.y, 250.0))


func _draw_label(text: String, position: Vector2, color: Color, font_size := 16) -> void:
	draw_string(
		ThemeDB.fallback_font,
		position,
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		font_size,
		color
	)


func _trace_label(line_id: String) -> String:
	return {
		"face": "脸的轮廓",
		"hand": "挥起的手",
		"bag": "旧书包",
		"inner_lane": "跑道内圈",
		"desk_scratch_path": "桌面划痕小路",
	}.get(line_id, "发亮的小路")
