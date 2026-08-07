extends Control

const StoryCatalog = preload("res://scripts/content/story_content_catalog.gd")
const InteractionBoardScript = preload("res://scripts/interactions/interaction_board.gd")

const ART := {
	"title": "res://assets/art/title_key_art.png",
	"reality": "res://assets/art/backgrounds/reality_room.png",
	"01_grey_morning": "res://assets/art/backgrounds/chapter_01.png",
	"02_looping_school": "res://assets/art/backgrounds/chapter_02.png",
	"03_paper_friends": "res://assets/art/backgrounds/chapter_03.png",
	"04_cabinet_breath": "res://assets/art/backgrounds/chapter_04.png",
	"05_after_forest": "res://assets/art/backgrounds/chapter_05.png",
}

const CHAPTER_END_LINES := {
	"01_grey_morning": "今天友军好像比昨天多一点。",
	"02_looping_school": "原来我以前真的很会玩。",
	"03_paper_friends": "画歪了，但看得出来很喜欢。",
	"04_cabinet_breath": "先躲一下，也很好。",
	"05_after_forest": "没有标准答案，也还想再往前看看。",
}

var _background: TextureRect
var _shade: ColorRect
var _screen_host: Control
var _toast: Label
var _current_scene: Dictionary = {}
var _current_scene_id := ""
var _interaction_board: Control
var _feedback_label: Label
var _hint_button: Button
var _observation_card: Control
var _completion_reveal: Control
var _scene_feedback_enabled := false
var _scene_complete := false
var _scene_started_at := 0
var _theme: Theme


func _ready() -> void:
	set_process_unhandled_input(true)
	_build_theme()
	_build_shell()
	AudioDirector.set_muted(SessionState.muted)
	_show_title()
	if OS.is_debug_build():
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--scene="):
				var preview_scene_id := argument.trim_prefix("--scene=")
				if StoryCatalog.has_scene(preview_scene_id):
					call_deferred("_open_debug_scene", preview_scene_id)
				break


func _open_debug_scene(scene_id: String) -> void:
	# Visual QA may jump to any authored scene without altering the player's
	# persisted story. Public state transitions still prepare a valid chapter.
	GameState.autosave_enabled = false
	var target_scene := StoryCatalog.get_scene(scene_id)
	var target_chapter_id := String(target_scene.get("chapter_id", ""))
	for chapter_id in StoryCatalog.get_chapter_ids():
		if chapter_id == target_chapter_id:
			break
		if not GameState.is_chapter_completed(chapter_id):
			if GameState.current_chapter != chapter_id:
				GameState.select_chapter(chapter_id)
			for phase in ["entry", "inner_world", "echo"]:
				GameState.set_progress(phase)
			GameState.complete_chapter(chapter_id)
	if GameState.current_chapter != target_chapter_id:
		GameState.select_chapter(target_chapter_id)
	_open_scene(scene_id)


func _unhandled_input(event: InputEvent) -> void:
	if _completion_reveal != null and event.is_action_pressed("ui_accept"):
		_advance_scene()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		_show_title()
		get_viewport().set_input_as_handled()


func _build_theme() -> void:
	_theme = Theme.new()
	var font := load("res://assets/fonts/NotoSansCJKsc-Regular.otf") as Font
	if font != null:
		_theme.default_font = font
	_theme.default_font_size = 22

	# Navigation is treated as ink laid over the scene, not as an app control.
	# A faint wash appears only while the player focuses or presses an action.
	var normal := _style(Color("#0a12151a"), Color.TRANSPARENT, 0, 4)
	var hover := _style(Color("#d9bc7b24"), Color("#e4c98a88"), 1, 4)
	var pressed := _style(Color("#c2764b40"), Color("#f0d49c"), 1, 4)
	var disabled := _style(Color.TRANSPARENT, Color.TRANSPARENT, 0, 4)
	_theme.set_stylebox("normal", "Button", normal)
	_theme.set_stylebox("hover", "Button", hover)
	_theme.set_stylebox("pressed", "Button", pressed)
	_theme.set_stylebox("focus", "Button", hover)
	_theme.set_stylebox("disabled", "Button", disabled)
	_theme.set_color("font_color", "Button", Color("#fff3d5"))
	_theme.set_color("font_hover_color", "Button", Color.WHITE)
	_theme.set_color("font_disabled_color", "Button", Color("#8b9495"))
	_theme.set_constant("outline_size", "Label", 5)
	_theme.set_color("font_outline_color", "Label", Color("#111820aa"))


func _build_shell() -> void:
	theme = _theme
	_background = TextureRect.new()
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

	_shade = ColorRect.new()
	_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shade.color = Color("#07101666")
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shade)

	_screen_host = Control.new()
	_screen_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_screen_host)

	_toast = Label.new()
	_toast.visible = false
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast.add_theme_font_size_override("font_size", 19)
	_toast.add_theme_stylebox_override("normal", _style(Color("#1f2b31ee"), Color("#dfc489"), 2, 16))
	_toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast.position = Vector2(-230, 88)
	_toast.size = Vector2(460, 58)
	_toast.z_index = 20
	add_child(_toast)


func _clear_screen() -> void:
	for child in _screen_host.get_children():
		child.queue_free()
	_interaction_board = null
	_feedback_label = null
	_hint_button = null
	_observation_card = null
	_completion_reveal = null
	_scene_feedback_enabled = false
	_scene_complete = false


func _show_title() -> void:
	_clear_screen()
	_set_background("title", Color("#07101822"))
	AudioDirector.set_scene("01_grey_morning", "opening", "title")

	var fade := TextureRect.new()
	fade.position = Vector2(0, 500)
	fade.size = Vector2(720, 780)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color.TRANSPARENT, Color("#071018e0")])
	gradient.offsets = PackedFloat32Array([0.0, 0.68])
	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.0)
	gradient_texture.fill_to = Vector2(0.5, 1.0)
	fade.texture = gradient_texture
	_screen_host.add_child(fade)

	var margin := MarginContainer.new()
	margin.position = Vector2(64, 650)
	margin.size = Vector2(592, 560)
	_set_margins(margin, 30, 12, 30, 18)
	_screen_host.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	margin.add_child(column)

	var title := _label("我", 88, Color("#fff2d0"))
	_scene_caption_style(title, 5)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var subtitle := _label("M E  A G A I N", 16, Color("#c98562"))
	_scene_caption_style(subtitle, 4)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(subtitle)
	var divider := _label("——", 18, Color("#b99762"))
	_scene_caption_style(divider, 4)
	divider.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(divider)

	var continue_button := _button("继续走", _continue_game)
	continue_button.tooltip_text = "上次停下的地方还亮着"
	column.add_child(continue_button)
	column.add_child(_button("从第一缕晨光开始", _request_new_game))
	column.add_child(_button("翻看章节", _show_chapter_select))
	var utility := HBoxContainer.new()
	utility.add_theme_constant_override("separation", 20)
	var sound_button := _button("听见声音" if SessionState.muted else "关掉声音", _toggle_audio)
	sound_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	utility.add_child(sound_button)
	var credits_button := _button("纸页背面", _show_credits)
	credits_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	utility.add_child(credits_button)
	column.add_child(utility)


func _continue_game() -> void:
	var chapter_id: String = GameState.current_chapter
	if GameState.chapter_progress == "complete":
		var index := StoryCatalog.get_chapter_ids().find(chapter_id)
		var ids := StoryCatalog.get_chapter_ids()
		if index >= 0 and index < ids.size() - 1 and GameState.is_chapter_unlocked(ids[index + 1]):
			chapter_id = ids[index + 1]
			GameState.select_chapter(chapter_id)
	var scene_id := SessionState.get_resume_scene(chapter_id)
	_open_scene(scene_id)


func _request_new_game() -> void:
	if GameState.visited_echoes.is_empty() and GameState.chapter_progress == "opening":
		_start_new_game()
		return
	var overlay := Control.new()
	overlay.name = "RestartPage"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 14
	_screen_host.add_child(overlay)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#0710158c")
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(scrim)
	var card := PanelContainer.new()
	card.position = Vector2(72, 426)
	card.size = Vector2(576, 386)
	card.add_theme_stylebox_override("panel", _paper_style(Color("#efdfc8fa")))
	overlay.add_child(card)
	var margin := MarginContainer.new()
	_set_margins(margin, 34, 34, 34, 28)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	margin.add_child(column)
	var title := _label("要从第一缕晨光重新来过吗？", 29, Color("#202627"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(title)
	var note := _label("已经收进铁皮盒的东西会回到原来的地方。", 19, Color("#625546"))
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size.y = 82
	column.add_child(note)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 24)
	column.add_child(actions)
	var stay := _button("留下现在", overlay.queue_free)
	_paper_action_colors(stay)
	stay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(stay)
	var restart := _button("重新开始", func() -> void:
		overlay.queue_free()
		_start_new_game()
	)
	_paper_action_colors(restart)
	restart.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(restart)


func _start_new_game() -> void:
	if not GameState.clear_save_and_start_new():
		_show_toast("存档暂时无法重置。")
		return
	SessionState.clear_resume()
	_open_scene(StoryCatalog.get_first_scene_id("01_grey_morning"))


func _show_chapter_select() -> void:
	_clear_screen()
	_set_background("reality", Color("#11182088"))
	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_set_margins(outer, 42, 70, 42, 44)
	_screen_host.add_child(outer)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	outer.add_child(column)
	var header := HBoxContainer.new()
	header.add_child(_button("←", _show_title, 72))
	var title := _label("章节", 40, Color("#fff0cf"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_child(title)
	header.add_child(_button("收藏", _show_collection, 110))
	column.add_child(header)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var cards := VBoxContainer.new()
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("separation", 14)
	scroll.add_child(cards)
	for chapter_id in StoryCatalog.get_chapter_ids():
		var chapter := StoryCatalog.get_chapter(chapter_id)
		var unlocked := GameState.is_chapter_unlocked(chapter_id)
		var complete := GameState.is_chapter_completed(chapter_id)
		var label := "%02d  %s" % [chapter["number"], chapter["title"]]
		if complete:
			label += "  · 已走过"
		elif not unlocked:
			label += "  · 未开启"
		var button := _button(label, _select_chapter.bind(chapter_id))
		button.disabled = not unlocked
		button.custom_minimum_size.y = 100
		button.tooltip_text = String(chapter["theme"])
		cards.add_child(button)
		var theme_line := _label(String(chapter["theme"]), 18, Color("#d4c7ad") if unlocked else Color("#777d7d"))
		theme_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cards.add_child(theme_line)


func _select_chapter(chapter_id: String) -> void:
	if not GameState.select_chapter(chapter_id):
		_show_toast("这一章还没有打开。")
		return
	var first := StoryCatalog.get_first_scene_id(chapter_id)
	SessionState.set_scene(first)
	_open_scene(first)


func _open_scene(scene_id: String) -> void:
	if not StoryCatalog.has_scene(scene_id):
		_show_title()
		return
	_current_scene_id = scene_id
	_current_scene = StoryCatalog.get_scene(scene_id)
	var chapter_id: String = _current_scene["chapter_id"]
	if GameState.current_chapter != chapter_id:
		if not GameState.select_chapter(chapter_id):
			_show_chapter_select()
			return
	_align_story_progress(String(_current_scene["phase"]))
	SessionState.set_scene(scene_id)
	_scene_started_at = Time.get_ticks_msec()
	_build_game_screen()
	AudioDirector.set_scene(chapter_id, String(_current_scene["phase"]), scene_id)


func _align_story_progress(target_phase: String) -> void:
	var stages := ["opening", "entry", "inner_world", "echo"]
	var current_index := stages.find(GameState.chapter_progress)
	var target_index := stages.find(target_phase)
	if current_index < 0 or current_index > target_index:
		GameState.select_chapter(GameState.current_chapter)
		current_index = 0
	while current_index < target_index:
		current_index += 1
		GameState.set_progress(stages[current_index])


func _build_game_screen() -> void:
	_clear_screen()
	var phase: String = _current_scene["phase"]
	var background_key := "reality" if phase == "echo" or _current_scene_id == "c01_s01_room_morning" else String(_current_scene["chapter_id"])
	var tint := Color("#07131a55")
	if phase == "opening":
		tint = Color("#0d17204a")
	elif phase == "inner_world":
		tint = Color("#17211833")
	elif phase == "echo":
		tint = Color("#2c211133")
	_set_background(background_key, tint)

	# A light HUD leaves the illustration as the actual play field.  The small
	# text actions are secondary navigation, not the scene's interaction.
	var top := MarginContainer.new()
	top.position = Vector2(16, 16)
	top.size = Vector2(688, 80)
	top.z_index = 6
	_screen_host.add_child(top)
	var top_margin := MarginContainer.new()
	_set_margins(top_margin, 8, 4, 8, 4)
	top.add_child(top_margin)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	top_margin.add_child(top_row)
	top_row.add_child(_button("退回", _show_title, 82))
	var chapter := StoryCatalog.get_chapter(String(_current_scene["chapter_id"]))
	var chapter_label := _label("第%d章 · %s\n%s" % [chapter["number"], chapter["title"], _phase_name(phase)], 17, Color("#f4e5c5"))
	chapter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(chapter_label)
	top_row.add_child(_button("铁皮盒 · %d" % GameState.collected_items.size(), _show_collection, 132))
	top_row.add_child(_button("%s" % ("静音" if not SessionState.muted else "听见"), _toggle_audio, 78))

	# Scene interaction spans nearly the full illustration. Narrative text is a
	# mouse-transparent caption above it, so low objects such as the school gate,
	# desk edge and fossil table remain reachable in their painted positions.
	_interaction_board = InteractionBoardScript.new()
	_interaction_board.position = Vector2(0, 82)
	_interaction_board.size = Vector2(720, 1166)
	_interaction_board.custom_minimum_size = Vector2(720, 1166)
	_screen_host.add_child(_interaction_board)
	_interaction_board.completed.connect(_on_interaction_completed)
	_interaction_board.feedback_changed.connect(_on_feedback_changed)
	_interaction_board.collectible_requested.connect(_on_collectible_requested)
	_interaction_board.sfx_requested.connect(AudioDirector.play_sfx)
	_interaction_board.configure(_current_scene, GameState.collected_items)
	_scene_feedback_enabled = true

	var story_card := Control.new()
	story_card.name = "SceneCaption"
	story_card.position = Vector2(0, 920)
	story_card.size = Vector2(720, 336)
	story_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	story_card.z_index = 5
	_screen_host.add_child(story_card)
	var fade := TextureRect.new()
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color.TRANSPARENT, Color("#071015b8")])
	gradient.offsets = PackedFloat32Array([0.0, 0.48])
	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.0)
	gradient_texture.fill_to = Vector2(0.5, 1.0)
	fade.texture = gradient_texture
	story_card.add_child(fade)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_margins(margin, 34, 72, 34, 10)
	story_card.add_child(margin)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 3)
	margin.add_child(column)
	var scene_title := _label(String(_current_scene["title"]), 27, Color("#fff0cf"))
	_scene_caption_style(scene_title, 8)
	column.add_child(scene_title)
	var narrative := _label(String(_current_scene["narrative"]), 18, Color("#f0e6d4"))
	_scene_caption_style(narrative, 7)
	narrative.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	narrative.custom_minimum_size.y = 48
	column.add_child(narrative)
	var objective := _label(String(_current_scene["objective"]), 16, Color("#e8c98e"))
	_scene_caption_style(objective, 7)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective.custom_minimum_size.y = 34
	column.add_child(objective)
	_feedback_label = _label("风声、光线，还有没被注意过的小东西。", 16, Color("#c9d7d3"))
	_scene_caption_style(_feedback_label, 7)
	_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_label.custom_minimum_size.y = 36
	column.add_child(_feedback_label)

	_hint_button = _button("翻开一角", _show_hint, 150)
	_hint_button.position = Vector2(536, 1174)
	_hint_button.size = Vector2(156, 58)
	_hint_button.z_index = 6
	_screen_host.add_child(_hint_button)

	# The entry caption gives the scene its first breath, then yields the whole
	# illustration back to play. Later actions communicate through observation
	# cards instead of leaving permanent copy over low scene targets.
	story_card.modulate.a = 0.0
	var caption_tween := create_tween()
	caption_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	caption_tween.tween_property(story_card, "modulate:a", 1.0, 0.24)
	caption_tween.tween_interval(3.1)
	caption_tween.set_ease(Tween.EASE_IN)
	caption_tween.tween_property(story_card, "modulate:a", 0.0, 0.55)


func _on_feedback_changed(text: String, tone := "neutral") -> void:
	if _feedback_label == null:
		return
	_feedback_label.text = text
	var colors := {
		"neutral": Color("#c9d7d3"),
		"warm": Color("#f0ca83"),
		"soft_error": Color("#d3c5b7"),
	}
	_feedback_label.add_theme_color_override("font_color", colors.get(tone, colors["neutral"]))
	if _scene_feedback_enabled and not _scene_complete:
		_show_observation_card(text, tone)


func _show_hint() -> void:
	_on_feedback_changed("纸角背面 · %s" % String(_current_scene["hint"]), "warm")
	_hint_button.disabled = true
	AudioDirector.play_sfx("paper")


func _on_collectible_requested(item_id: String) -> void:
	if GameState.collect_item(item_id):
		var item := StoryCatalog.get_collectible(item_id)
		var note := "收进铁皮盒 · %s" % String(item.get("name", item_id))
		_show_toast(note)
		_show_observation_card(note, "warm")
		AudioDirector.play_sfx("glass" if item_id.contains("marble") else "paper")
	else:
		_show_toast("它已经在铁皮盒里。")


func _on_interaction_completed(metrics: Dictionary = {}) -> void:
	if _scene_complete:
		return
	_scene_complete = true
	_on_feedback_changed(String(_current_scene["completion_feedback"]), "warm")
	AudioDirector.play_sfx("success")
	_log_playtest(metrics)
	if String(_current_scene["next_scene_id"]).is_empty():
		if GameState.complete_chapter(String(_current_scene["chapter_id"])):
			SessionState.clear_resume()
	_show_completion_reveal()


func _show_observation_card(text: String, tone := "neutral") -> void:
	if text.strip_edges().is_empty() or _screen_host == null:
		return
	if _observation_card != null and is_instance_valid(_observation_card):
		_observation_card.queue_free()
	var card := PanelContainer.new()
	card.name = "ObservationCard"
	card.position = Vector2(62, 684)
	card.size = Vector2(596, 176)
	card.z_index = 8
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", _paper_style(Color("#f0dfc8f2") if tone != "soft_error" else Color("#dfd5c7f2")))
	_screen_host.add_child(card)
	_observation_card = card

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_margins(margin, 12, 12, 18, 12)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)
	var crop := _scene_crop(Vector2(146, 146))
	row.add_child(crop)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 6)
	row.add_child(column)
	var mark := _label("刚才那一幕", 15, Color("#8b6543"))
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(mark)
	var note := _label(text, 20, Color("#252b2c"))
	note.mouse_filter = Control.MOUSE_FILTER_IGNORE
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(note)

	var target_y := card.position.y
	card.position.y += 18
	card.modulate.a = 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(card, "position:y", target_y, 0.22)
	tween.tween_interval(1.65)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(card, "modulate:a", 0.0, 0.18)
	tween.tween_callback(card.queue_free)


func _show_completion_reveal() -> void:
	if _completion_reveal != null or _screen_host == null:
		return
	var overlay := Control.new()
	overlay.name = "MemoryReveal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	overlay.z_index = 12
	overlay.gui_input.connect(_on_completion_reveal_input)
	_screen_host.add_child(overlay)
	_completion_reveal = overlay

	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#07101582")
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(scrim)

	var card := PanelContainer.new()
	card.position = Vector2(48, 278)
	card.size = Vector2(624, 708)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", _paper_style(Color("#f0dfc9fa")))
	overlay.add_child(card)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_margins(margin, 24, 22, 24, 22)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	var crop := _scene_crop(Vector2(576, 280))
	column.add_child(crop)
	var scene_title := _label(String(_current_scene["title"]), 22, Color("#80583a"))
	scene_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(scene_title)
	var line := _label(String(_current_scene["completion_feedback"]), 28, Color("#202627"))
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.custom_minimum_size.y = 92
	column.add_child(line)
	var echo := _label(String(_current_scene["narrative"]), 18, Color("#4f514e"))
	echo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	echo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	echo.custom_minimum_size.y = 86
	column.add_child(echo)
	var turn := _label("纸角翘了起来", 17, Color("#9a6842"))
	turn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	turn.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	column.add_child(turn)

	card.pivot_offset = card.size * 0.5
	card.scale = Vector2(0.965, 0.965)
	card.modulate.a = 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(card, "scale", Vector2.ONE, 0.24)


func _on_completion_reveal_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_advance_scene()
	elif event is InputEventScreenTouch and event.pressed:
		_advance_scene()


func _scene_crop(minimum_size: Vector2) -> TextureRect:
	var crop := TextureRect.new()
	crop.texture = _background.texture
	crop.custom_minimum_size = minimum_size
	crop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	crop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	crop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return crop


func _advance_scene() -> void:
	if not _scene_complete:
		return
	var next_scene: String = _current_scene["next_scene_id"]
	if not next_scene.is_empty():
		_open_scene(next_scene)
		return
	_show_chapter_complete(String(_current_scene["chapter_id"]))


func _show_chapter_complete(chapter_id: String) -> void:
	_clear_screen()
	_set_background("reality", Color("#2a201055"))
	var chapter := StoryCatalog.get_chapter(chapter_id)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _style(Color("#152329ee"), Color("#dfc28a"), 2, 28))
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.position = Vector2(-300, -320)
	card.size = Vector2(600, 640)
	_screen_host.add_child(card)
	var margin := MarginContainer.new()
	_set_margins(margin, 38, 42, 38, 36)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 22)
	margin.add_child(column)
	var kicker := _label("第%d章 · 已走过" % int(chapter["number"]), 18, Color("#d2b780"))
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(kicker)
	var title := _label(String(chapter["title"]), 44, Color("#fff0ce"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var line := _label(CHAPTER_END_LINES[chapter_id], 28, Color("#eee1c7"))
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.custom_minimum_size.y = 130
	column.add_child(line)
	column.add_child(_collection_summary())
	var ids := StoryCatalog.get_chapter_ids()
	var index := ids.find(chapter_id)
	if index < ids.size() - 1:
		var next_id: String = ids[index + 1]
		var next_chapter := StoryCatalog.get_chapter(next_id)
		column.add_child(_button("下一章 · %s" % next_chapter["title"], _start_chapter.bind(next_id)))
	else:
		column.add_child(_button("回到普通晨光", _show_ending))
	column.add_child(_button("返回章节", _show_chapter_select))


func _start_chapter(chapter_id: String) -> void:
	if not GameState.select_chapter(chapter_id):
		_show_chapter_select()
		return
	_open_scene(StoryCatalog.get_first_scene_id(chapter_id))


func _show_ending() -> void:
	_clear_screen()
	_set_background("reality", Color("#1b130c33"))
	AudioDirector.set_scene("05_after_forest", "echo", "ending")
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _style(Color("#172329ea"), Color("#e3c88d"), 2, 28))
	card.position = Vector2(42, 170)
	card.size = Vector2(636, 930)
	_screen_host.add_child(card)
	var margin := MarginContainer.new()
	_set_margins(margin, 38, 44, 38, 36)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 22)
	margin.add_child(column)
	var title := _label("还是一个普通早晨", 42, Color("#fff0ce"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var prose := _label("工作没有变成理想工作，房间也没有发生奇迹。\n\n只是他买了一支真正喜欢的笔，绕远路看了一排树，又给很久没联系的朋友发了一条消息。\n\n镜子里的他还是成年人的脸。笑起来的时候，却有一点像那个还愿意相信门会自己出现的小孩。", 23, Color("#e9dfc9"))
	prose.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prose.custom_minimum_size.y = 430
	column.add_child(prose)
	column.add_child(_collection_summary())
	column.add_child(_button("翻到章节页", _show_chapter_select))
	column.add_child(_button("回到标题", _show_title))


func _show_collection() -> void:
	var popup := PopupPanel.new()
	popup.name = "CollectionPopup"
	popup.add_theme_stylebox_override("panel", _style(Color("#16242af5"), Color("#d9bd82"), 2, 24))
	_screen_host.add_child(popup)
	var margin := MarginContainer.new()
	_set_margins(margin, 30, 30, 30, 30)
	popup.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var title := _label("铁皮盒", 34, Color("#fff0ce"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	for item_id in StoryCatalog.COLLECTIBLES.keys():
		var item: Dictionary = StoryCatalog.get_collectible(item_id)
		var found := GameState.has_item(item_id)
		var row := _label(("◆ " if found else "◇ ") + (String(item["name"]) if found else "还没有遇见"), 20, Color("#f2dfb7") if found else Color("#758086"))
		row.tooltip_text = String(item["description"]) if found else "盒底还空着。"
		column.add_child(row)
	column.add_child(_button("收好", popup.hide))
	popup.popup_centered(Vector2i(600, 790))


func _collection_summary() -> Label:
	var count := GameState.collected_items.size()
	var label := _label("铁皮盒里收着 %d / %d 件小东西。" % [count, StoryCatalog.COLLECTIBLES.size()], 18, Color("#cdb98f"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.y = 58
	return label


func _show_credits() -> void:
	_clear_screen()
	_set_background("title", Color("#071018aa"))
	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_set_margins(outer, 42, 62, 42, 42)
	_screen_host.add_child(outer)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	outer.add_child(column)
	var header := HBoxContainer.new()
	header.add_child(_button("←", _show_title, 72))
	var title := _label("制作与授权", 38, Color("#fff0ce"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_child(title)
	header.add_spacer(false)
	column.add_child(header)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var text := _label("叙事基准\n《我》五章小说式母本\n\n美术\n使用 OpenAI imagegen 生成原创章节场景，并在工程中保留生成提示与资产清单。\n\n音乐与声音（CC0）\nCenturion_of_war · Aureolus_Omicron · TinyWorlds · isaiah658 · IgnasD · alxl · SketchMan3 · Yaroslav_Novikov · GboxMikeFozzy · rubberduck\n来源：OpenGameArt，完整链接与逐文件授权见 docs/audio-licenses.md。\n\n字体\nNoto Sans CJK SC，SIL Open Font License 1.1。\n\n制作原则\n不解释里世界究竟是梦、记忆还是自我修复；不把现实写成已经被解决。", 21, Color("#e8deca"))
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(610, 900)
	scroll.add_child(text)


func _toggle_audio() -> void:
	SessionState.set_muted(not SessionState.muted)
	AudioDirector.set_muted(SessionState.muted)
	for node in _screen_host.find_children("*", "Button", true, false):
		var button := node as Button
		if button == null:
			continue
		if button.text in ["关掉声音", "听见声音"]:
			button.text = "听见声音" if SessionState.muted else "关掉声音"
		elif button.text in ["静音", "听见"]:
			button.text = "听见" if SessionState.muted else "静音"
	_show_toast("声音已%s。" % ("关闭" if SessionState.muted else "打开"))


func _set_background(key: String, tint: Color) -> void:
	var path: String = ART.get(key, ART["reality"])
	_background.texture = load(path) as Texture2D
	_shade.color = tint


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 0.0
	_toast.visible = true
	var tween := create_tween()
	tween.tween_property(_toast, "modulate:a", 1.0, 0.18)
	tween.tween_interval(1.7)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func(): _toast.visible = false)


func _log_playtest(metrics: Dictionary) -> void:
	var base_dir := ProjectSettings.globalize_path("user://me_again")
	DirAccess.make_dir_recursive_absolute(base_dir)
	var file := FileAccess.open("user://me_again/playtest.ndjson", FileAccess.READ_WRITE)
	if file == null:
		return
	file.seek_end()
	var record := metrics.duplicate(true)
	record["sceneId"] = _current_scene_id
	record["chapterId"] = _current_scene["chapter_id"]
	record["durationMs"] = Time.get_ticks_msec() - _scene_started_at
	record["timestamp"] = Time.get_datetime_string_from_system(true)
	file.store_line(JSON.stringify(record))


func _phase_name(phase: String) -> String:
	return {
		"opening": "现实",
		"entry": "入界",
		"inner_world": "里世界",
		"echo": "现实回声",
	}.get(phase, phase)


func _button(text: String, callback: Callable, minimum_width := 0) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(minimum_width, 54)
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_stylebox_override("normal", _ink_action_style(Color.TRANSPARENT, Color.TRANSPARENT, 0))
	button.add_theme_stylebox_override("hover", _ink_action_style(Color("#d9bc7b0d"), Color("#e4c98a99"), 2))
	button.add_theme_stylebox_override("pressed", _ink_action_style(Color("#c2764b18"), Color("#f0d49c"), 2))
	button.add_theme_stylebox_override("focus", _ink_action_style(Color.TRANSPARENT, Color("#f0d49c"), 2))
	button.add_theme_color_override("font_hover_color", Color("#ffe7b4"))
	button.add_theme_color_override("font_pressed_color", Color("#fff0cf"))
	button.pressed.connect(callback)
	return button


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _scene_caption_style(label: Label, outline_size := 7) -> void:
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_outline_color", Color("#071015e8"))
	label.add_theme_constant_override("outline_size", outline_size)
	label.add_theme_color_override("font_shadow_color", Color("#071015cc"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)


func _paper_action_colors(button: Button) -> void:
	button.add_theme_color_override("font_color", Color("#3d332b"))
	button.add_theme_color_override("font_hover_color", Color("#855532"))
	button.add_theme_color_override("font_pressed_color", Color("#5f3d27"))
	button.add_theme_color_override("font_focus_color", Color("#3d332b"))


func _style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _paper_style(fill: Color = Color("#efe0cadf")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color("#75543772")
	style.border_width_left = 1
	style.border_width_top = 2
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.set_corner_radius_all(3)
	style.shadow_color = Color("#07101555")
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	return style


func _ink_action_style(fill: Color, line: Color, line_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = line
	style.border_width_bottom = line_width
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 9
	style.content_margin_bottom = 7
	return style


func _set_margins(container: MarginContainer, left: int, top: int, right: int, bottom: int) -> void:
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)
