class_name InteractionBoard
extends Control

## Reusable 680x500 interaction renderer for the 17 StoryContentCatalog contracts.
##
## Usage:
##     var board := InteractionBoard.new()
##     add_child(board)
##     board.configure(StoryContentCatalog.get_scene(scene_id))
##
## The board never writes GameState directly. Its four public signals form the
## integration boundary for scene flow, feedback, inventory and audio.

signal completed(metrics: Dictionary)
signal feedback_changed(text: String, tone: String)
signal collectible_requested(item_id: String)
signal sfx_requested(kind: String)

const ModelScript = preload("res://scripts/interactions/interaction_model.gd")
const DragTokenScript = preload("res://scripts/interactions/interaction_drag_token.gd")
const DropSlotScript = preload("res://scripts/interactions/interaction_drop_slot.gd")
const GestureSurfaceScript = preload("res://scripts/interactions/interaction_gesture_surface.gd")
const HotspotScript = preload("res://scripts/interactions/interaction_hotspot.gd")
const SceneLayoutStore = preload("res://scripts/interactions/interaction_scene_layout_store.gd")

const COLOR_PANEL := Color(0.0, 0.0, 0.0, 0.0)
const COLOR_WORKSPACE := Color(0.0, 0.0, 0.0, 0.0)
const COLOR_TEXT := Color("e9ecea")
const COLOR_MUTED := Color("aebbb6")
const COLOR_WARM := Color("e8cf96")
const COLOR_GENTLE := Color("c6b8ac")
const COLOR_COMPLETE := Color("9dd4b9")

const LABELS := {
	"alarm": "闹钟", "cup": "水杯", "shirt": "衬衫", "keys": "钥匙", "door_lock": "门锁",
	"window": "窗户", "phone": "手机", "headlight": "车灯", "plate": "车牌",
	"car_round_eye": "圆眼小车", "car_sleepy_eye": "困眼小车", "car_narrow_eye": "窄眼小车",
	"car_red_tail": "红尾小车", "car_tiny_van": "小小面包车", "friend_route": "友军路线",
	"enemy_route": "敌军路线", "seatbelt_pin": "安全带扣", "route_confirm": "安全出口",
	"green": "绿灯", "red": "红灯", "red_light": "红灯", "tree": "窗外的树",
	"gate": "旧校门", "track_shadow": "操场影子", "wall_corner": "外墙拐角", "start_loop": "沿墙出发",
	"track_line": "跑道线", "chalk_corridor_shadow": "粉笔线尽头", "hint_no_turn": "这里先别拐",
	"hint_slow_fourth": "第四圈慢一点", "hint_short_shadow": "影子短的那边", "desk_mark": "桌面划痕",
	"drawer_note": "抽屉字条", "chalk": "半截粉笔", "star": "贴纸星星", "desk_corner": "桌角",
	"old_manga": "旧漫画", "pencil": "铅笔", "old_paper": "临摹纸", "open_manga": "打开漫画",
	"round_friend": "圆脸朋友", "brow_friend": "皱眉朋友", "bag_friend": "书包朋友",
	"panel_corridor": "分镜走廊", "like": "喜欢", "wait": "期待", "proud": "得意", "bye": "告别",
	"old_bookmark": "旧书签", "stage_gap": "舞台缺口", "friend_bow": "朋友谢幕", "new_book": "新漫画",
	"bookmark": "书签", "receipt": "收据", "messages": "未读消息", "desk_drawer": "抽屉",
	"overhead_light": "顶灯", "close_laptop": "合上电脑", "cabinet_door": "柜门", "rain": "雨声",
	"steps": "脚步声", "breath": "呼吸声", "door": "门外", "bag": "书包", "book_cabinet": "课本柜",
	"leaf_cabinet": "树叶柜", "empty_cabinet": "空柜", "forest_shadow_door": "树影门",
	"plastic_ruler": "透明塑料尺", "lamp": "台灯", "chair": "安静坐下", "old_school": "旧学校",
	"forest_shadow": "树影", "mud": "潮泥", "forest_path": "林间小路", "blackboard": "黑板",
	"manga_page": "漫画页", "cabinet": "柜门", "fossil_table": "泥台", "fossil_box": "透明盒",
	"why_book": "科普书", "old_mud": "旧泥土", "new_pen": "新笔", "fossil": "化石",
	"marble": "玻璃弹珠", "arrange_items": "摆好喜欢的东西", "send_friend_message": "给朋友发消息",
	"face": "脸的轮廓", "hand": "挥起的手", "inner_lane": "跑道内圈",
	"desk_scratch_path": "桌面小路", "outer_wall_loop": "学校外墙",
	"drag_inside": "缩进柜子", "set_narrow_gap": "留窄门缝", "hold_breath_slow": "呼吸三拍",
	"drag_branch": "拨开枝叶", "tap_shadow": "碰一下树影", "hold_two_fingers": "双指停住",
	"separate": "两指分开", "lift": "一起抬起", "hold": "一起守住",
}

var _scene: Dictionary = {}
var _already_collected: Array[String] = []
var _model = ModelScript.new()
var _shell: PanelContainer
var _title_label: Label
var _objective_label: Label
var _content: VBoxContainer
var _feedback_label: Label
var _progress_label: Label
var _hint_button: Button
var _surface
var _buttons: Dictionary = {}
var _tokens: Dictionary = {}
var _drop_slots: Dictionary = {}
var _completion_emitted := false

var _hold_started_msec := 0
var _hold_target := ""
var _hold_model_action := ""
var _hold_short_action := ""
var _hold_required := 0.0
var _hold_button: Button
var _hold_default_text := ""
var _hold_fired := false

var _gap_slider: HSlider
var _gap_label: Label
var _gap_sent := false


func _ready() -> void:
	custom_minimum_size = Vector2(640.0, 460.0)
	_build_shell()
	set_process(true)
	if not _scene.is_empty():
		_apply_scene()


func configure(scene_data: Dictionary, already_collected: Array = []) -> void:
	_scene = scene_data.duplicate(true)
	_already_collected = _strings(already_collected)
	_model.configure(_scene)
	_completion_emitted = false
	_clear_hold()
	if is_node_ready():
		_apply_scene()


func reset_interaction() -> void:
	if not _scene.is_empty():
		configure(_scene, _already_collected)


func submit_action(action: String, target_id := "", data: Dictionary = {}) -> Dictionary:
	var result: Dictionary = _model.dispatch(action, target_id, data)
	_apply_result(result)
	return result


func get_metrics() -> Dictionary:
	return _model.metrics()


func get_interaction_state() -> Dictionary:
	return _model.snapshot()


func _build_shell() -> void:
	for child in get_children():
		child.queue_free()
	_shell = PanelContainer.new()
	_shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shell.add_theme_stylebox_override("panel", _panel_style(COLOR_PANEL, 0.0, Color.TRANSPARENT, 0.0))
	add_child(_shell)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	_shell.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 7)
	margin.add_child(layout)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 22)
	_title_label.add_theme_color_override("font_color", COLOR_TEXT)
	layout.add_child(_title_label)
	_title_label.visible = false

	_objective_label = Label.new()
	_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objective_label.add_theme_font_size_override("font_size", 15)
	_objective_label.add_theme_color_override("font_color", COLOR_MUTED)
	_objective_label.custom_minimum_size.y = 38.0
	layout.add_child(_objective_label)
	_objective_label.visible = false

	var workspace := PanelContainer.new()
	workspace.size_flags_vertical = Control.SIZE_EXPAND_FILL
	workspace.custom_minimum_size.y = 520.0
	workspace.add_theme_stylebox_override("panel", _panel_style(COLOR_WORKSPACE, 0.0, Color.TRANSPARENT, 0.0))
	layout.add_child(workspace)

	var workspace_margin := MarginContainer.new()
	workspace_margin.add_theme_constant_override("margin_left", 4)
	workspace_margin.add_theme_constant_override("margin_right", 4)
	workspace_margin.add_theme_constant_override("margin_top", 2)
	workspace_margin.add_theme_constant_override("margin_bottom", 2)
	workspace.add_child(workspace_margin)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 8)
	workspace_margin.add_child(_content)

	_feedback_label = Label.new()
	_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_label.add_theme_font_size_override("font_size", 15)
	_feedback_label.add_theme_color_override("font_color", COLOR_WARM)
	_feedback_label.custom_minimum_size.y = 34.0
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.add_theme_color_override("font_shadow_color", Color(0.05, 0.05, 0.04, 0.92))
	_feedback_label.add_theme_constant_override("shadow_offset_x", 1)
	_feedback_label.add_theme_constant_override("shadow_offset_y", 2)
	layout.add_child(_feedback_label)
	_feedback_label.visible = false

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	layout.add_child(footer)
	footer.visible = false

	_progress_label = Label.new()
	_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress_label.add_theme_color_override("font_color", COLOR_MUTED)
	footer.add_child(_progress_label)

	_hint_button = HotspotScript.new()
	_hint_button.setup("hint", "？")
	_hint_button.tooltip_text = "纸角背面写着一句话"
	_hint_button.custom_minimum_size = Vector2(48.0, 48.0)
	_hint_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_hint_button.pressed.connect(_show_hint)
	footer.add_child(_hint_button)


func _apply_scene() -> void:
	if _shell == null:
		return
	for child in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	_buttons.clear()
	_tokens.clear()
	_drop_slots.clear()
	_surface = null
	_gap_slider = null
	_gap_label = null
	_gap_sent = false

	_title_label.text = String(_scene.get("title", "互动"))
	_objective_label.text = String(_scene.get("objective", "附近传来一点动静。"))
	_set_feedback(String(_scene.get("hint", "声音从画面里传来。")), "calm")

	match _model.interaction_type():
		"hotspot_sequence", "collect_clues", "compare_spaces", "echo_revisit", "repeat_observe":
			_build_observation()
		"sort_targets", "slot_placement":
			_build_assignment()
		"path_route":
			_build_route()
		"rhythm_sequence":
			_build_rhythm()
		"repeat_path":
			_build_loop()
		"path_trace", "trace_lines":
			_build_trace()
		"reorder_sequence":
			_build_reorder()
		"drag_place":
			_build_drag_place()
		"repeat_toggle":
			_build_repeat_toggle()
		"posture_sequence":
			_build_posture()
		"multi_touch_sequence":
			_build_multi_touch()
		_:
			var missing := Label.new()
			missing.text = "这个互动暂时没有可用的呈现方式。"
			_content.add_child(missing)
	_update_progress()


func _build_observation() -> void:
	var contract: Dictionary = _scene.get("interaction", {})
	var field := Control.new()
	field.custom_minimum_size = Vector2(600.0, 490.0)
	field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(field)
	var target_ids := _strings(contract.get("target_ids", []))
	var spot_index := 0
	for target_id in target_ids:
		var button := _make_button(target_id)
		_place_hotspot(field, button, spot_index, target_ids.size() + 1)
		spot_index += 1
	var finish_id := String(contract.get("finish_target_id", ""))
	if not finish_id.is_empty() and not _buttons.has(finish_id):
		var finish_button := _make_button(finish_id)
		_place_hotspot(field, finish_button, spot_index, target_ids.size() + 1)
		spot_index += 1

	for optional_id in _strings(contract.get("optional_target_ids", [])):
		var optional = HotspotScript.new()
		optional.setup(optional_id, _label_for(optional_id))
		optional.pressed.connect(_on_optional_tap.bind(optional_id))
		_place_hotspot(field, optional, spot_index, target_ids.size() + 2)
		spot_index += 1

	for action_id in _strings(contract.get("required_actions", [])):
		var action_button = HotspotScript.new()
		action_button.setup(action_id, _label_for(action_id))
		action_button.pressed.connect(_on_special_action.bind(action_id))
		_place_hotspot(field, action_button, spot_index, target_ids.size() + 2)
		spot_index += 1
		_buttons[action_id] = action_button

	if _model.interaction_type() == "echo_revisit" and not finish_id.is_empty():
		var hold_button: Button = _buttons.get(finish_id)
		if hold_button != null:
			var tap_callable := _on_tap.bind(finish_id)
			if hold_button.pressed.is_connected(tap_callable):
				hold_button.pressed.disconnect(tap_callable)
			for connection in hold_button.gui_input.get_connections():
				hold_button.gui_input.disconnect(connection.callable)
			hold_button.gui_input.connect(_on_holdable_input.bind(
				hold_button,
				finish_id,
				"hold",
				float(contract.get("hold_seconds", 1.0)),
				""
			))


func _build_assignment() -> void:
	var contract: Dictionary = _scene.get("interaction", {})
	var assignments: Dictionary = contract.get("assignments", {})
	var field := Control.new()
	field.custom_minimum_size = Vector2(600.0, 490.0)
	field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(field)
	var token_index := 0
	for item_value in assignments.keys():
		var item_id := String(item_value)
		var token = DragTokenScript.new()
		token.setup(item_id, _label_for(item_id))
		token.drag_cancelled.connect(_on_drag_cancelled)
		_place_scene_node(field, token, item_id, Vector2(0.3 + token_index * 0.18, 0.15), Vector2(132, 100))
		token_index += 1
		_tokens[item_id] = token
	var slot_ids := _strings(contract.get("slots", []))
	if slot_ids.is_empty():
		for value in assignments.values():
			var id := String(value)
			if not slot_ids.has(id):
				slot_ids.append(id)
	for slot_index in slot_ids.size():
		var slot_id := slot_ids[slot_index]
		var slot = DropSlotScript.new()
		slot.setup(slot_id, _label_for(slot_id), _strings(assignments.keys()))
		slot.token_dropped.connect(_on_token_dropped)
		_place_scene_node(field, slot, slot_id, Vector2(0.3 + slot_index * 0.4, 0.72), Vector2(250, 130))
		_drop_slots[slot_id] = slot


func _build_route() -> void:
	_surface = GestureSurfaceScript.new()
	_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_surface.configure_route()
	_surface.route_resolved.connect(_on_route_resolved)
	_surface.surface_feedback.connect(_set_feedback)
	_content.add_child(_surface)


func _build_rhythm() -> void:
	var contract: Dictionary = _scene.get("interaction", {})
	var field := Control.new()
	field.custom_minimum_size = Vector2(600.0, 390.0)
	field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(field)
	var input_ids := _strings(contract.get("input_ids", []))
	for index in input_ids.size():
		var input_id := input_ids[index]
		var button := _make_button(input_id)
		button.custom_minimum_size = Vector2(130.0, 100.0)
		button.add_theme_font_size_override("font_size", 20)
		_place_hotspot(field, button, index, input_ids.size())


func _build_loop() -> void:
	_surface = GestureSurfaceScript.new()
	_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_surface.configure_loop()
	_surface.lap_detected.connect(_on_lap_detected)
	_surface.surface_feedback.connect(_set_feedback)
	_content.add_child(_surface)


func _build_trace() -> void:
	var contract: Dictionary = _scene.get("interaction", {})
	var clues := _strings(contract.get("clue_ids", []))
	var prerequisite := String(contract.get("prerequisite_target_id", ""))
	var trace_ids: Array[String] = []
	if _model.interaction_type() == "trace_lines":
		trace_ids = _strings(contract.get("line_ids", []))
	else:
		trace_ids.append(String(contract.get("path_id", "path")))
	_surface = GestureSurfaceScript.new()
	_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_surface.configure_trace(trace_ids, String(contract.get("tolerance", "wide")) == "wide")
	_surface.trace_resolved.connect(_on_trace_resolved)
	_surface.surface_feedback.connect(_set_feedback)
	var field := Control.new()
	field.custom_minimum_size = Vector2(600.0, 490.0)
	field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(field)
	field.add_child(_surface)
	_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var target_count := clues.size() + (1 if not prerequisite.is_empty() else 0)
	var target_index := 0
	if not prerequisite.is_empty():
		_place_hotspot(field, _make_button(prerequisite), target_index, target_count)
		target_index += 1
	for clue_id in clues:
		_place_hotspot(field, _make_button(clue_id), target_index, target_count)
		target_index += 1


func _build_reorder() -> void:
	var contract: Dictionary = _scene.get("interaction", {})
	var cards := _strings(contract.get("card_ids", []))

	var field := Control.new()
	field.custom_minimum_size = Vector2(600.0, 490.0)
	field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(field)
	for card_index in cards.size():
		var card_id := cards[card_index]
		var token = DragTokenScript.new()
		token.setup(card_id, _label_for(card_id))
		token.drag_cancelled.connect(_on_drag_cancelled)
		_place_scene_node(field, token, card_id, Vector2(0.2 + card_index * 0.2, 0.88), Vector2(112, 92))
		_tokens[card_id] = token
	for index in cards.size():
		var slot_id := "order_%d" % index
		var slot = DropSlotScript.new()
		slot.setup(slot_id, "第 %d 格" % (index + 1), cards)
		slot.token_dropped.connect(_on_token_dropped)
		_place_scene_node(field, slot, slot_id, Vector2(0.27 + (index % 2) * 0.45, 0.35 + (index / 2) * 0.35), Vector2(225, 150))
		_drop_slots[slot_id] = slot


func _build_drag_place() -> void:
	var contract: Dictionary = _scene.get("interaction", {})
	var source_id := String(contract.get("source_id", ""))
	var slot_id := String(contract.get("slot_id", ""))

	var field := Control.new()
	field.custom_minimum_size = Vector2(600.0, 490.0)
	field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(field)
	var token = DragTokenScript.new()
	token.setup(source_id, _label_for(source_id))
	token.custom_minimum_size = Vector2(150.0, 58.0)
	token.drag_cancelled.connect(_on_drag_cancelled)
	_place_scene_node(field, token, source_id, Vector2(0.28, 0.72), Vector2(150, 128))
	_tokens[source_id] = token

	var slot = DropSlotScript.new()
	slot.setup(slot_id, _label_for(slot_id), [source_id])
	slot.custom_minimum_size = Vector2(180.0, 116.0)
	slot.token_dropped.connect(_on_token_dropped)
	_place_scene_node(field, slot, slot_id, Vector2(0.55, 0.18), Vector2(220, 150))
	_drop_slots[slot_id] = slot


func _build_repeat_toggle() -> void:
	var contract: Dictionary = _scene.get("interaction", {})
	var target_id := String(contract.get("target_id", "cabinet_door"))

	var button = HotspotScript.new()
	button.setup(target_id, "柜门")
	button.custom_minimum_size = Vector2(250.0, 190.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 21)
	button.gui_input.connect(_on_holdable_input.bind(
		button,
		target_id,
		"hold",
		float(contract.get("hold_seconds", 1.2)),
		"toggle"
	))
	var field := Control.new()
	field.custom_minimum_size = Vector2(600.0, 490.0)
	field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(field)
	_place_hotspot(field, button, 0, 1)
	_buttons[target_id] = button


func _build_posture() -> void:
	var body_row := HBoxContainer.new()
	body_row.alignment = BoxContainer.ALIGNMENT_CENTER
	body_row.add_theme_constant_override("separation", 34)
	_content.add_child(body_row)
	var body_token = DragTokenScript.new()
	body_token.setup("drag_inside", "蜷起的身体")
	body_token.drag_cancelled.connect(_on_drag_cancelled)
	body_row.add_child(body_token)
	_tokens["drag_inside"] = body_token
	var cabinet_slot = DropSlotScript.new()
	cabinet_slot.setup("cabinet_inside", "柜子里面", ["drag_inside"])
	cabinet_slot.token_dropped.connect(_on_posture_drop)
	body_row.add_child(cabinet_slot)
	_drop_slots["cabinet_inside"] = cabinet_slot

	var gap_row := HBoxContainer.new()
	gap_row.add_theme_constant_override("separation", 10)
	_content.add_child(gap_row)
	_gap_label = Label.new()
	_gap_label.text = "门缝：还太宽"
	_gap_label.custom_minimum_size.x = 100.0
	gap_row.add_child(_gap_label)
	_gap_slider = HSlider.new()
	_gap_slider.min_value = 0.0
	_gap_slider.max_value = 100.0
	_gap_slider.value = 100.0
	_gap_slider.step = 1.0
	_gap_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gap_slider.tooltip_text = "门缝收窄到一指宽"
	_gap_slider.value_changed.connect(_on_gap_changed)
	gap_row.add_child(_gap_slider)

	var breath_button = HotspotScript.new()
	breath_button.setup("hold_breath_slow", "呼吸")
	breath_button.custom_minimum_size = Vector2(180.0, 82.0)
	breath_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	breath_button.gui_input.connect(_on_holdable_input.bind(
		breath_button,
		"hold_breath_slow",
		"posture",
		float(_scene.get("interaction", {}).get("hold_seconds", 3.0)),
		""
	))
	_content.add_child(breath_button)
	_buttons["hold_breath_slow"] = breath_button


func _build_multi_touch() -> void:
	var contract: Dictionary = _scene.get("interaction", {})
	var order := _strings(contract.get("required_order", []))
	_surface = GestureSurfaceScript.new()
	_surface.custom_minimum_size.y = 190.0
	_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_surface.configure_multi(order)
	_surface.multi_gesture.connect(_on_multi_gesture)
	_surface.surface_feedback.connect(_set_feedback)
	_content.add_child(_surface)

	var fallback_row := HBoxContainer.new()
	fallback_row.alignment = BoxContainer.ALIGNMENT_CENTER
	fallback_row.add_theme_constant_override("separation", 7)
	_content.add_child(fallback_row)
	for index in order.size():
		var action_id := order[index]
		var button = HotspotScript.new()
		button.setup(action_id, "%d  %s" % [index + 1, _label_for(action_id)])
		button.tooltip_text = "数字键 %d 也会唤醒这道影子" % (index + 1)
		button.custom_minimum_size = Vector2(145.0, 64.0)
		button.pressed.connect(_on_multi_fallback.bind(action_id))
		fallback_row.add_child(button)
		_buttons[action_id] = button


func _make_button(target_id: String) -> Button:
	var button = HotspotScript.new()
	button.setup(target_id, _label_for(target_id))
	button.pressed.connect(_on_tap.bind(target_id))
	_buttons[target_id] = button
	return button


func _place_hotspot(field: Control, hotspot: Control, index: int, total: int) -> void:
	# Every authored scene resolves its targets against the actual painted
	# background. The asymmetric list is only a defensive fallback for future
	# catalog additions that have not received art direction yet.
	var positions := [
		Vector2(0.17, 0.23), Vector2(0.52, 0.16), Vector2(0.82, 0.31),
		Vector2(0.28, 0.58), Vector2(0.67, 0.57), Vector2(0.87, 0.76),
		Vector2(0.45, 0.82), Vector2(0.10, 0.79),
	]
	var target_id := String(hotspot.get("hotspot_id"))
	var fallback: Vector2 = positions[index % positions.size()]
	if total <= 2:
		fallback = [Vector2(0.30, 0.48), Vector2(0.72, 0.51)][index % 2]
	_place_scene_node(field, hotspot, target_id, fallback, Vector2(150.0, 120.0))


func _place_scene_node(
	field: Control,
	node: Control,
	semantic_id: String,
	fallback_anchor: Vector2,
	fallback_size: Vector2
) -> void:
	var scene_id := String(_scene.get("id", ""))
	var placement: Dictionary = SceneLayoutStore.target(scene_id, semantic_id)
	var anchor: Vector2 = placement.get("anchor", fallback_anchor)
	var hit_size: Vector2 = placement.get("hit_size", fallback_size)
	if node.has_method("set_scene_presentation"):
		node.set_scene_presentation(String(placement.get("mode", "sprite")))
	if node.has_method("set_scene_visual"):
		node.set_scene_visual(
			String(placement.get("asset_path", "")),
			placement.get("visual_size", hit_size)
		)
	node.z_index = int(placement.get("z_index", 1))
	field.add_child(node)
	node.set_anchor(SIDE_LEFT, anchor.x)
	node.set_anchor(SIDE_RIGHT, anchor.x)
	node.set_anchor(SIDE_TOP, anchor.y)
	node.set_anchor(SIDE_BOTTOM, anchor.y)
	node.offset_left = -hit_size.x * 0.5
	node.offset_right = hit_size.x * 0.5
	node.offset_top = -hit_size.y * 0.5
	node.offset_bottom = hit_size.y * 0.5


func _on_tap(target_id: String) -> void:
	submit_action("tap", target_id)


func _on_optional_tap(target_id: String) -> void:
	_set_feedback("%s也有了动静。" % _label_for(target_id), "calm")
	sfx_requested.emit("observe")


func _on_special_action(action_id: String) -> void:
	submit_action("special", action_id)


func _on_drag_cancelled(_item_id: String) -> void:
	_set_feedback("纸片滑回原处。", "gentle")


func _on_token_dropped(item_id: String, slot_id: String) -> void:
	if _model.interaction_type() == "reorder_sequence":
		var index := int(slot_id.trim_prefix("order_"))
		submit_action("drop", item_id, {"index": index, "slot_id": slot_id})
	else:
		submit_action("drop", item_id, {"slot_id": slot_id})


func _on_route_resolved(data: Dictionary) -> void:
	submit_action("route", String(_scene.get("interaction", {}).get("handle_id", "")), data)


func _on_lap_detected(data: Dictionary) -> void:
	submit_action("lap", String(_scene.get("interaction", {}).get("path_id", "")), data)


func _on_trace_resolved(line_id: String, data: Dictionary) -> void:
	var result := submit_action("trace", line_id, data)
	if bool(result.get("accepted", false)) and bool(data.get("success", false)) and _surface != null:
		_surface.advance_trace()


func _on_posture_drop(item_id: String, _slot_id: String) -> void:
	if item_id != "drag_inside":
		return
	var result := submit_action("posture", "drag_inside", {"source": "drag"})
	if bool(result.get("accepted", false)):
		_gap_slider.value = 100.0


func _on_gap_changed(value: float) -> void:
	if _gap_label == null:
		return
	if value > 48.0:
		_gap_label.text = "门缝：还太宽"
	elif value < 14.0:
		_gap_label.text = "门缝：几乎合上"
	else:
		_gap_label.text = "门缝：一指宽"
	if not _gap_sent and value >= 18.0 and value <= 40.0:
		var result := submit_action("posture", "set_narrow_gap", {"gap_percent": value})
		if bool(result.get("accepted", false)):
			_gap_sent = true


func _on_multi_gesture(action_id: String, data: Dictionary) -> void:
	var result := submit_action("multi", action_id, data)
	if bool(result.get("accepted", false)) and _surface != null:
		_surface.set_multi_step(int(_model.snapshot().get("sequence_index", 0)))


func _on_multi_fallback(action_id: String) -> void:
	var data := {"fallback": "mouse_button"}
	if action_id in ["hold_two_fingers", "hold"]:
		data["seconds"] = 0.8
	_on_multi_gesture(action_id, data)


func _on_holdable_input(
	event: InputEvent,
	button: Button,
	target_id: String,
	model_action: String,
	required_seconds: float,
	short_action: String
) -> void:
	var is_press_event: bool = (
		(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT)
		or event is InputEventScreenTouch
	)
	if not is_press_event:
		return
	if event.pressed:
		_hold_started_msec = Time.get_ticks_msec()
		_hold_target = target_id
		_hold_model_action = model_action
		_hold_short_action = short_action
		_hold_required = required_seconds
		_hold_button = button
		_hold_default_text = button.text
		_hold_fired = false
		return
	if _hold_button != button or _hold_started_msec <= 0:
		return
	var seconds := float(Time.get_ticks_msec() - _hold_started_msec) / 1000.0
	if not _hold_fired:
		if seconds + 0.01 >= _hold_required:
			submit_action(_hold_model_action, _hold_target, {"seconds": seconds})
		elif not _hold_short_action.is_empty():
			submit_action(_hold_short_action, _hold_target, {"seconds": seconds})
		else:
			_set_feedback("光圈还没走完，手指先别离开。", "gentle")
	_clear_hold()


func _process(_delta: float) -> void:
	if _hold_button == null or _hold_started_msec <= 0 or _hold_fired:
		return
	if not is_instance_valid(_hold_button):
		_clear_hold()
		return
	var seconds := float(Time.get_ticks_msec() - _hold_started_msec) / 1000.0
	var remaining := maxf(0.0, _hold_required - seconds)
	if _hold_button.has_method("set_hold_progress"):
		_hold_button.set_hold_progress(clampf(seconds / maxf(_hold_required, 0.01), 0.0, 1.0))
	else:
		_hold_button.text = "呼吸还差 %.1f 秒" % remaining
	if seconds + 0.01 >= _hold_required:
		_hold_fired = true
		submit_action(_hold_model_action, _hold_target, {"seconds": seconds})
		_clear_hold()


func _clear_hold() -> void:
	if _hold_button != null and is_instance_valid(_hold_button) and _hold_button.has_method("set_hold_progress"):
		_hold_button.set_hold_progress(-1.0)
	if _hold_button != null and is_instance_valid(_hold_button) and not _hold_default_text.is_empty():
		_hold_button.text = _hold_default_text
	_hold_started_msec = 0
	_hold_target = ""
	_hold_model_action = ""
	_hold_short_action = ""
	_hold_required = 0.0
	_hold_button = null
	_hold_default_text = ""
	_hold_fired = false


func _apply_result(result: Dictionary) -> void:
	_set_feedback(String(result.get("feedback", "")), String(result.get("tone", "calm")))
	var sfx := String(result.get("sfx", ""))
	if not sfx.is_empty():
		sfx_requested.emit(sfx)
	_refresh_interactive_state()
	_update_progress()

	if bool(result.get("just_completed", false)) and not _completion_emitted:
		_completion_emitted = true
		for item_id in _strings(_scene.get("collectibles", [])):
			if not _already_collected.has(item_id):
				collectible_requested.emit(item_id)
		completed.emit(result.get("metrics", {}).duplicate(true))


func _refresh_interactive_state() -> void:
	var state: Dictionary = _model.snapshot()
	var visited := _strings(state.get("visited", []))
	var performed := _strings(state.get("performed", []))
	var placements: Dictionary = state.get("placements", {})
	var done := bool(state.get("completed", false))

	for key in _buttons.keys():
		var target_id := String(key)
		var button: Button = _buttons[key]
		if not is_instance_valid(button):
			continue
		if target_id == _hold_target:
			continue
		var marked := visited.has(target_id) or performed.has(target_id)
		if marked and _model.interaction_type() not in ["repeat_observe", "repeat_toggle"]:
			if button.has_method("set_found"):
				button.set_found(true)
			else:
				button.text = "✓ %s" % _label_for(target_id)
			button.disabled = done

	match _model.interaction_type():
		"sort_targets", "slot_placement":
			for item_key in _tokens.keys():
				var item_id := String(item_key)
				var token = _tokens[item_key]
				token.locked = placements.has(item_id) or done
			if not placements.is_empty():
				for slot in _drop_slots.values():
					slot.clear_content()
				for item_key in placements.keys():
					var slot_id := String(placements[item_key])
					if _drop_slots.has(slot_id):
						_drop_slots[slot_id].set_content(_label_for(String(item_key)))
		"reorder_sequence":
			for slot in _drop_slots.values():
				slot.clear_content()
			for index_key in placements.keys():
				var slot_id := "order_%d" % int(index_key)
				if _drop_slots.has(slot_id):
					_drop_slots[slot_id].set_content(_label_for(String(placements[index_key])))
			for token in _tokens.values():
				token.locked = done
		"drag_place":
			for token_key in _tokens.keys():
				_tokens[token_key].locked = placements.has(String(token_key)) or done
			for source_key in placements.keys():
				var slot_id := String(placements[source_key])
				if _drop_slots.has(slot_id):
					_drop_slots[slot_id].set_content(_label_for(String(source_key)))
		"posture_sequence":
			var posture_index := int(state.get("sequence_index", 0))
			if _tokens.has("drag_inside"):
				_tokens["drag_inside"].locked = posture_index >= 1 or done
			if posture_index >= 1 and _drop_slots.has("cabinet_inside"):
				_drop_slots["cabinet_inside"].set_content("柜壁贴住了肩膀")
			if _gap_slider != null:
				_gap_slider.editable = posture_index == 1 and not done
		"multi_touch_sequence":
			if _surface != null:
				_surface.set_multi_step(int(state.get("sequence_index", 0)))

	for slot in _drop_slots.values():
		slot.locked = done


func _update_progress() -> void:
	if _progress_label == null:
		return
	var state: Dictionary = _model.snapshot()
	var contract: Dictionary = _scene.get("interaction", {})
	if bool(state.get("completed", false)):
		_progress_label.text = "四周安静下来"
		return
	match _model.interaction_type():
		"hotspot_sequence", "collect_clues", "compare_spaces", "echo_revisit":
			var required := int(contract.get("required_count", _strings(contract.get("target_ids", [])).size()))
			_progress_label.text = "已看见 %d / %d" % [mini(state.get("visited", []).size(), required), required]
		"repeat_observe":
			_progress_label.text = "再次观察 %d / %d" % [state.get("sequence_index", 0), contract.get("repeat_count", 1)]
		"sort_targets", "slot_placement":
			_progress_label.text = "已放好 %d / %d" % [state.get("placements", {}).size(), contract.get("assignments", {}).size()]
		"rhythm_sequence":
			_progress_label.text = "口令 %d / %d" % [state.get("sequence_index", 0), _strings(contract.get("required_order", [])).size()]
		"repeat_path":
			_progress_label.text = "绕行 %d / %d · 最后一圈要慢" % [state.get("lap_count", 0), contract.get("repeat_count", 1)]
		"trace_lines":
			_progress_label.text = "描线 %d / %d · 允许画歪" % [state.get("trace_ids", []).size(), contract.get("required_count", 1)]
		"reorder_sequence":
			_progress_label.text = "已放入 %d / %d 张分镜" % [state.get("placements", {}).size(), _strings(contract.get("card_ids", [])).size()]
		"repeat_toggle":
			_progress_label.text = "柜门开合 %d / %d · 最后按住" % [state.get("toggle_count", 0), contract.get("repeat_count", 1)]
		"posture_sequence", "multi_touch_sequence":
			_progress_label.text = "动作 %d / %d" % [state.get("sequence_index", 0), _strings(contract.get("required_order", [])).size()]
		_:
			_progress_label.text = "眼前还有一点动静"


func _show_hint() -> void:
	_set_feedback(String(_scene.get("hint", "纸角背面没有字。")), "calm")
	sfx_requested.emit("hint")


func _set_feedback(text: String, tone: String) -> void:
	if _feedback_label != null:
		_feedback_label.text = text
		_feedback_label.add_theme_color_override("font_color", {
			"gentle": COLOR_GENTLE,
			"warm": COLOR_WARM,
			"complete": COLOR_COMPLETE,
		}.get(tone, COLOR_MUTED))
	feedback_changed.emit(text, tone)


func _unhandled_key_input(event: InputEvent) -> void:
	if _model.interaction_type() != "multi_touch_sequence" or not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	var order := _strings(_scene.get("interaction", {}).get("required_order", []))
	var index := -1
	match event.keycode:
		KEY_1, KEY_KP_1:
			index = 0
		KEY_2, KEY_KP_2:
			index = 1
		KEY_3, KEY_KP_3:
			index = 2
	if index >= 0 and index < order.size():
		var data := {"fallback": "keyboard"}
		if order[index] in ["hold_two_fingers", "hold"]:
			data["seconds"] = 0.8
		_on_multi_gesture(order[index], data)
		get_viewport().set_input_as_handled()


func _label_for(id: String) -> String:
	if LABELS.has(id):
		return String(LABELS[id])
	if id.begins_with("enemy_node"):
		return "太亮的敌军位置"
	if id.begins_with("order_"):
		return "顺序格"
	return "可观察物件"


func _strings(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array or values is PackedStringArray:
		for value in values:
			result.append(String(value))
	return result


func _panel_style(color: Color, radius: float, border_color: Color, border_width: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(int(border_width))
	style.corner_radius_top_left = int(radius)
	style.corner_radius_top_right = int(radius)
	style.corner_radius_bottom_left = int(radius)
	style.corner_radius_bottom_right = int(radius)
	return style
