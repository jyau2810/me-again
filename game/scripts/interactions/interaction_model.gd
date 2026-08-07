class_name InteractionModel
extends RefCounted

## Pure, deterministic state machine for every interaction renderer contract.
##
## InteractionBoard owns presentation and translates pointer/keyboard input into
## calls to [method dispatch]. Keeping rules here makes the interactions usable in
## headless tests and prevents a scene reload from being the only way to recover
## from an imprecise gesture.

const SUPPORTED_TYPES: PackedStringArray = [
	"hotspot_sequence",
	"repeat_observe",
	"sort_targets",
	"path_route",
	"rhythm_sequence",
	"echo_revisit",
	"repeat_path",
	"path_trace",
	"collect_clues",
	"trace_lines",
	"reorder_sequence",
	"drag_place",
	"repeat_toggle",
	"slot_placement",
	"compare_spaces",
	"posture_sequence",
	"multi_touch_sequence",
]

var _scene: Dictionary = {}
var _contract: Dictionary = {}
var _interaction_type := ""
var _completed := false
var _started_msec := 0
var _action_count := 0
var _retry_count := 0
var _visited: Array[String] = []
var _performed: Array[String] = []
var _placements: Dictionary = {}
var _sequence_index := 0
var _lap_count := 0
var _toggle_count := 0
var _trace_ids: Array[String] = []
var _accuracy_total := 0.0
var _accuracy_samples := 0


func configure(scene_data: Dictionary) -> void:
	_scene = scene_data.duplicate(true)
	_contract = _scene.get("interaction", {}).duplicate(true)
	_interaction_type = String(_scene.get("interaction_type", ""))
	_completed = false
	_started_msec = Time.get_ticks_msec()
	_action_count = 0
	_retry_count = 0
	_visited.clear()
	_performed.clear()
	_placements.clear()
	_sequence_index = 0
	_lap_count = 0
	_toggle_count = 0
	_trace_ids.clear()
	_accuracy_total = 0.0
	_accuracy_samples = 0


func is_supported() -> bool:
	return SUPPORTED_TYPES.has(_interaction_type)


func is_completed() -> bool:
	return _completed


func interaction_type() -> String:
	return _interaction_type


func contract() -> Dictionary:
	return _contract.duplicate(true)


func snapshot() -> Dictionary:
	return {
		"interaction_type": _interaction_type,
		"completed": _completed,
		"visited": _visited.duplicate(),
		"performed": _performed.duplicate(),
		"placements": _placements.duplicate(true),
		"sequence_index": _sequence_index,
		"lap_count": _lap_count,
		"toggle_count": _toggle_count,
		"trace_ids": _trace_ids.duplicate(),
		"action_count": _action_count,
		"retry_count": _retry_count,
	}


func metrics() -> Dictionary:
	var elapsed := maxf(0.0, float(Time.get_ticks_msec() - _started_msec) / 1000.0)
	return {
		"scene_id": String(_scene.get("id", "")),
		"interaction_type": _interaction_type,
		"completed": _completed,
		"elapsed_seconds": snappedf(elapsed, 0.01),
		"action_count": _action_count,
		"retry_count": _retry_count,
		"observed_count": _visited.size(),
		"placed_count": _placements.size(),
		"lap_count": _lap_count,
		"accuracy": (
			snappedf(_accuracy_total / float(_accuracy_samples), 0.001)
			if _accuracy_samples > 0
			else 1.0
		),
	}


## Standard actions are `tap`, `drop`, `route`, `lap`, `trace`, `toggle`,
## `hold`, `posture`, `multi`, and `special`. The optional data dictionary is
## intentionally serializable so replays and accessibility adapters can use it.
func dispatch(action: String, target_id := "", data: Dictionary = {}) -> Dictionary:
	if _completed:
		return _response(false, "这一幕已经安静下来了。", "calm")

	_action_count += 1
	match _interaction_type:
		"hotspot_sequence", "collect_clues", "compare_spaces":
			return _dispatch_observation(action, target_id)
		"repeat_observe":
			return _dispatch_repeat_observe(action, target_id)
		"sort_targets":
			return _dispatch_assignment(action, target_id, data, "车辆")
		"slot_placement":
			return _dispatch_assignment(action, target_id, data, "声音")
		"path_route":
			return _dispatch_route(action, data)
		"rhythm_sequence":
			return _dispatch_rhythm(action, target_id)
		"echo_revisit":
			return _dispatch_echo(action, target_id, data)
		"repeat_path":
			return _dispatch_repeat_path(action, data)
		"path_trace":
			return _dispatch_path_trace(action, target_id, data)
		"trace_lines":
			return _dispatch_trace_lines(action, target_id, data)
		"reorder_sequence":
			return _dispatch_reorder(action, target_id, data)
		"drag_place":
			return _dispatch_drag_place(action, target_id, data)
		"repeat_toggle":
			return _dispatch_repeat_toggle(action, target_id, data)
		"posture_sequence":
			return _dispatch_ordered_gestures(action, target_id, data, "posture")
		"multi_touch_sequence":
			return _dispatch_ordered_gestures(action, target_id, data, "multi")
		_:
			return _gentle("这里暂时没有动静。")


func _dispatch_observation(action: String, target_id: String) -> Dictionary:
	if action != "tap":
		return _gentle("指尖落到物件上，才会有回应。")

	var targets := _strings(_contract.get("target_ids", []))
	var finish_id := String(_contract.get("finish_target_id", ""))
	var required := int(_contract.get("required_count", targets.size()))

	if target_id == finish_id and not targets.has(finish_id):
		if _visited.size() >= required:
			return _complete()
		return _gentle("出口没动。附近还有一点声音没有停下。")
	if not targets.has(target_id):
		return _gentle("这里没有动静。")

	var is_new := _append_unique(_visited, target_id)
	if not is_new:
		return _response(true, "它和刚才一样。", "calm", "observe")

	var enough := _visited.size() >= required
	if enough and (finish_id.is_empty() or (targets.has(finish_id) and _visited.has(finish_id))):
		return _complete()
	if enough:
		return _response(true, "附近都安静了，只剩出口还有一点光。", "warm", "reveal")
	return _response(
		true,
		"别处还有一点响动。",
		"warm",
		"observe"
	)


func _dispatch_repeat_observe(action: String, target_id: String) -> Dictionary:
	var targets := _strings(_contract.get("target_ids", []))
	if action != "tap" or not targets.has(target_id):
		return _gentle("玻璃里的影子还在。")
	var needed := int(_contract.get("repeat_count", 1))
	_sequence_index += 1
	if _sequence_index >= needed:
		return _complete()
	return _response(
		true,
		"手机屏幕又暗了一次，玻璃里的影子更清楚了。",
		"warm",
		"observe"
	)


func _dispatch_assignment(
	action: String,
	item_id: String,
	data: Dictionary,
	_object_name: String
) -> Dictionary:
	if action != "drop":
		return _gentle("画面里有一处正发亮，它还留在原位。")
	var assignments: Dictionary = _contract.get("assignments", {})
	var slot_id := String(data.get("slot_id", ""))
	if not assignments.has(item_id) or not assignments.values().has(slot_id):
		return _gentle("它落空了。画面里还有一处在发亮。")
	if String(assignments[item_id]) != slot_id:
		_retry_count += 1
		return _gentle("它一落下，旁边的亮处反而暗了。")

	_placements[item_id] = slot_id
	if _placements.size() >= assignments.size():
		return _complete()
	return _response(
		true,
		"它稳稳落住，另一处亮了起来。",
		"warm",
		"place"
	)


func _dispatch_route(action: String, data: Dictionary) -> Dictionary:
	if action != "route":
		return _gentle("安全带扣正亮着，座椅边缘留出一条暗路。")
	if not bool(data.get("success", false)):
		_retry_count += 1
		if bool(data.get("hit_blocker", false)):
			return _gentle("亮处把路线照断了；座椅边缘还留着一条暗路。")
		return _gentle("这条线断在半路。安全带扣还亮着。")
	_accuracy_total += float(data.get("accuracy", 1.0))
	_accuracy_samples += 1
	return _complete()


func _dispatch_rhythm(action: String, target_id: String) -> Dictionary:
	if action != "tap":
		return _gentle("绿灯闪了两下，像在等同样的回应。")
	var order := _strings(_contract.get("required_order", []))
	if order.is_empty():
		return _complete()
	if not _strings(_contract.get("input_ids", [])).has(target_id):
		return _gentle("这盏灯没有接上刚才那一拍。")
	if target_id != order[_sequence_index]:
		_retry_count += 1
		if bool(_contract.get("reset_on_error", true)):
			_sequence_index = 0
		return _gentle("两盏灯同时暗了一下，口令又从“两个走”响起。")
	_sequence_index += 1
	if _sequence_index >= order.size():
		return _complete()
	return _response(true, "信号灯接上了下一拍。", "warm", "signal")


func _dispatch_echo(action: String, target_id: String, data: Dictionary) -> Dictionary:
	var targets := _strings(_contract.get("target_ids", []))
	var required := int(_contract.get("required_count", targets.size()))
	var finish_id := String(_contract.get("finish_target_id", ""))
	var required_actions := _strings(_contract.get("required_actions", []))

	if action == "tap" and targets.has(target_id):
		_append_unique(_visited, target_id)
	elif action == "special" and required_actions.has(target_id):
		_append_unique(_performed, target_id)
	elif action == "hold" and target_id == finish_id:
		var hold_needed := float(_contract.get("hold_seconds", 1.0))
		if float(data.get("seconds", 0.0)) + 0.01 < hold_needed:
			return _gentle("呼吸还没走完三拍，椅背上的光圈也没合上。")
		_append_unique(_performed, "finish_hold")
	else:
		return _gentle("这里没有动静。")

	var enough_targets := _visited.size() >= required
	var enough_actions := true
	for required_action in required_actions:
		if not _performed.has(required_action):
			enough_actions = false
			break
	var finish_done := finish_id.is_empty() or _performed.has("finish_hold")
	if enough_targets and enough_actions and finish_done:
		return _complete()

	if not enough_targets:
		return _response(
			true,
			"桌上还有几样东西没有安静下来。",
			"warm",
			"observe"
		)
	if not enough_actions:
		return _response(true, "桌面安静了，手机屏幕还亮着。", "warm", "reveal")
	return _response(true, "椅背抵住肩膀，光圈还没有合上。", "calm", "reveal")


func _dispatch_repeat_path(action: String, data: Dictionary) -> Dictionary:
	if action != "lap":
		return _gentle("墙边的细线围着学校绕了一整圈。")
	var needed := int(_contract.get("repeat_count", 1))
	var is_final := _lap_count == needed - 1
	var duration := float(data.get("duration", 0.0))
	var on_track_ratio := float(data.get("on_track_ratio", 1.0))
	if on_track_ratio < 0.45:
		_retry_count += 1
		return _gentle("粉笔线在脚边断开了，墙根那一段还亮着。")
	if is_final and String(_contract.get("final_pace", "")) == "slow":
		var slow_seconds := float(_contract.get("slow_lap_seconds", 1.8))
		if duration + 0.01 < slow_seconds:
			_retry_count += 1
			return _gentle("第四圈的脚步太急，粉笔灰没有落下。")
	_lap_count += 1
	_accuracy_total += clampf(on_track_ratio, 0.0, 1.0)
	_accuracy_samples += 1
	if _lap_count >= needed:
		return _complete()
	if _lap_count == needed - 1:
		return _response(true, "前三圈走完，第四圈的粉笔灰还没落下来。", "warm", "lap")
	return _response(true, "脚步又绕回墙边，粉笔线更清楚了。", "warm", "lap")


func _dispatch_path_trace(action: String, target_id: String, data: Dictionary) -> Dictionary:
	var clues := _strings(_contract.get("clue_ids", []))
	var prerequisite := String(_contract.get("prerequisite_target_id", ""))
	if action == "tap" and (clues.has(target_id) or target_id == prerequisite):
		_append_unique(_visited, target_id)
		return _response(true, "线索记住了。木纹和跑道正在连起来。", "warm", "observe")
	if action != "trace":
		return _gentle("木纹要从发亮的一端接到另一端。")

	var clue_needed := int(_contract.get("required_clue_count", clues.size()))
	if not prerequisite.is_empty() and not _visited.has(prerequisite):
		return _gentle("跑道线仍藏在桌面木纹里。")
	if clues.size() > 0 and _visited.size() < clue_needed:
		return _gentle("木纹里还有一道划痕没有接上。")
	if not bool(data.get("success", false)):
		_retry_count += 1
		return _gentle("线断在半路，开头还亮着。")
	_accuracy_total += float(data.get("accuracy", 1.0))
	_accuracy_samples += 1
	return _complete()


func _dispatch_trace_lines(action: String, target_id: String, data: Dictionary) -> Dictionary:
	if action != "trace":
		return _gentle("发亮的旧线从一端延伸到另一端。")
	var lines := _strings(_contract.get("line_ids", []))
	if not lines.has(target_id):
		return _gentle("别的旧线没有亮，只有这一道还留在纸上。")
	if not bool(data.get("success", false)):
		_retry_count += 1
		return _gentle("线头没有碰上旧线，虚线还留在原处。")
	if _append_unique(_trace_ids, target_id):
		_accuracy_total += float(data.get("accuracy", 1.0))
		_accuracy_samples += 1
	var required := int(_contract.get("required_count", lines.size()))
	if _trace_ids.size() >= required:
		return _complete()
	return _response(true, "这段线留下了，下一道旧线亮起来。", "warm", "pencil")


func _dispatch_reorder(action: String, card_id: String, data: Dictionary) -> Dictionary:
	if action != "drop":
		return _gentle("四个空格亮了，手里的分镜还没落下。")
	var cards := _strings(_contract.get("card_ids", []))
	var order := _strings(_contract.get("required_order", []))
	var index := int(data.get("index", -1))
	if not cards.has(card_id) or index < 0 or index >= order.size():
		return _gentle("四个格子还亮着，分镜悬在纸边。")

	for old_index in _placements.keys():
		if String(_placements[old_index]) == card_id:
			_placements.erase(old_index)
			break
	_placements[index] = card_id
	if _placements.size() < order.size():
		return _response(true, "纸边落进格子，还空着几格。", "warm", "paper")

	for expected_index in order.size():
		if String(_placements.get(expected_index, "")) != order[expected_index]:
			_retry_count += 1
			return _gentle("四格都满了，纸声却没连起来；有两格反了。", true)
	return _complete()


func _dispatch_drag_place(action: String, source_id: String, data: Dictionary) -> Dictionary:
	if action != "drop":
		return _gentle("旧书签留在纸边，舞台中央正缺一小块路。")
	if source_id != String(_contract.get("source_id", "")):
		return _gentle("要找的是舞台旁那张旧书签。")
	if String(data.get("slot_id", "")) != String(_contract.get("slot_id", "")):
		_retry_count += 1
		return _gentle("书签搭空了，舞台缺口还在中间。")
	_placements[source_id] = String(data.get("slot_id", ""))
	return _complete()


func _dispatch_repeat_toggle(action: String, target_id: String, data: Dictionary) -> Dictionary:
	if target_id != String(_contract.get("target_id", "")):
		return _gentle("柜门里，雨声比走廊更近。")
	var needed := int(_contract.get("repeat_count", 1))
	if action == "toggle" and _toggle_count < needed:
		_toggle_count += 1
		if _toggle_count >= needed:
			return _response(true, "第三次，手指没有离开柜门；雨声正贴过来。", "calm", "door")
		return _response(true, "柜门又开合一次，雨声贴近了。", "warm", "door")
	if action == "hold":
		var needed_seconds := float(_contract.get("hold_seconds", 1.2))
		if float(data.get("seconds", 0.0)) + 0.01 < needed_seconds:
			return _gentle("门缝里的雨声刚贴近，又退回窗外。")
		# The intended gesture is a long third opening. For accessibility, three
		# short taps followed by a hold is accepted too.
		if _toggle_count == needed - 1:
			_toggle_count += 1
		if _toggle_count >= needed:
			return _complete()
		return _gentle("雨点仍停在窗外，门缝里还没有回声。")
	return _gentle("柜门一碰就开合；手指不离开时，雨声停在门缝里。")


func _dispatch_ordered_gestures(
	action: String,
	target_id: String,
	data: Dictionary,
	expected_action: String
) -> Dictionary:
	if action != expected_action:
		return _gentle("亮起的影子还在等同一个动作。")
	var order := _strings(_contract.get("required_order", []))
	if _sequence_index >= order.size():
		return _complete()
	var expected := order[_sequence_index]
	if target_id != expected:
		_retry_count += 1
		return _gentle("“%s”的影子亮了。" % _gesture_label(expected))
	if expected == "hold_breath_slow":
		var hold_seconds := float(_contract.get("hold_seconds", 3.0))
		if float(data.get("seconds", 0.0)) + 0.01 < hold_seconds:
			return _gentle("光圈还没走完，手指先别离开。")
	if expected in ["hold_two_fingers", "hold"]:
		var touch_hold := float(_contract.get("touch_hold_seconds", 0.8))
		if float(data.get("seconds", touch_hold)) + 0.01 < touch_hold:
			return _gentle("两道影子刚碰到木板，木板还在晃。")

	_sequence_index += 1
	_append_unique(_performed, target_id)
	if _sequence_index >= order.size():
		return _complete()
	return _response(
		true,
		"“%s”的影子接着亮起。" % _gesture_label(order[_sequence_index]),
		"warm",
		"gesture"
	)


func _complete() -> Dictionary:
	_completed = true
	return _response(
		true,
		String(_scene.get("completion_feedback", "四周安静下来。")),
		"complete",
		"complete",
		true
	)


func _gentle(message: String, accepted := false) -> Dictionary:
	return _response(accepted, message, "gentle", "soft_miss")


func _response(
	accepted: bool,
	feedback: String,
	tone: String,
	sfx := "",
	just_completed := false
) -> Dictionary:
	return {
		"accepted": accepted,
		"feedback": feedback,
		"tone": tone,
		"sfx": sfx,
		"just_completed": just_completed,
		"completed": _completed,
		"state": snapshot(),
		"metrics": metrics(),
	}


func _append_unique(values: Array[String], value: String) -> bool:
	if value.is_empty() or values.has(value):
		return false
	values.append(value)
	return true


func _strings(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array or values is PackedStringArray:
		for value in values:
			result.append(String(value))
	return result


func _gesture_label(gesture: String) -> String:
	return {
		"drag_inside": "缩进柜子",
		"set_narrow_gap": "留一条窄门缝",
		"hold_breath_slow": "呼吸三拍",
		"drag_branch": "拨开枝叶",
		"tap_shadow": "碰一下树影",
		"hold_two_fingers": "两指一起停住",
		"separate": "两指分开",
		"lift": "两指一起抬起",
		"hold": "两指一起守住",
	}.get(gesture, gesture)
