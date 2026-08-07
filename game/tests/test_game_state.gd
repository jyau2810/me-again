extends RefCounted

const GameStateScript = preload("res://scripts/autoload/game_state.gd")
const Schema = preload("res://scripts/domain/game_schema.gd")
const SaveCodec = preload("res://scripts/domain/save_codec.gd")

var _assertion_count := 0
var _failures: Array[String] = []
var _test_root := OS.get_temp_dir().path_join("me_again_godot_tests")


func run() -> Dictionary:
	_test_default_state()
	_test_strict_five_chapter_progression()
	_test_invalid_operations_are_rejected()
	_test_save_whitelist_and_round_trip()
	_test_backup_recovery_and_default_fallback()
	_test_logical_corruption_is_sanitized()
	return {
		"assertions": _assertion_count,
		"failures": _failures.duplicate(),
	}


func _test_default_state() -> void:
	var state = _new_state("default.json")
	_expect(state.start_new_game(true), "new game can be persisted")
	var data: Dictionary = state.snapshot()
	_expect(data["currentChapter"] == Schema.CHAPTERS[0], "chapter 1 is current by default")
	_expect(data["chapterProgress"] == "opening", "new game starts at opening")
	_expect(data["perceptionStage"] == "opening", "new game perception is opening")
	_expect(data["collectedItems"].is_empty(), "new game has no collected items")
	_expect(data["visitedEchoes"].is_empty(), "new game has no visited echoes")
	_expect(state.is_chapter_unlocked(Schema.CHAPTERS[0]), "chapter 1 starts unlocked")
	for chapter_index in range(1, Schema.CHAPTERS.size()):
		_expect(
			not state.is_chapter_unlocked(Schema.CHAPTERS[chapter_index]),
			"later chapter %d starts locked" % (chapter_index + 1)
		)
	state.free()


func _test_strict_five_chapter_progression() -> void:
	var state = _new_state("progression.json")
	_expect(state.start_new_game(true), "progression fixture starts")
	var item_events: Array[String] = []
	var echo_events: Array[String] = []
	var unlock_events: Array[String] = []
	state.item_collected.connect(func(item_id: String) -> void: item_events.append(item_id))
	state.echo_visited.connect(func(echo_id: String) -> void: echo_events.append(echo_id))
	state.chapter_unlocked.connect(func(chapter_id: String) -> void: unlock_events.append(chapter_id))

	for chapter_index in Schema.CHAPTERS.size():
		var chapter_id: String = Schema.CHAPTERS[chapter_index]
		if chapter_index > 0:
			_expect(state.select_chapter(chapter_id), "select unlocked chapter %d" % (chapter_index + 1))

		var chapter_items: Array = Schema.ITEMS_BY_CHAPTER[chapter_id]
		for item_id in chapter_items:
			_expect(state.collect_item(item_id), "collect known item %s" % item_id)
			_expect(state.collect_item(item_id), "collect retry is idempotent for %s" % item_id)
			_expect(_occurrences(state.collected_items, item_id) == 1, "%s is only stored once" % item_id)

		_expect(state.set_progress("entry"), "chapter %d reaches entry" % (chapter_index + 1))
		_expect(state.set_progress("inner_world"), "chapter %d reaches inner world" % (chapter_index + 1))
		_expect(state.set_progress("echo"), "chapter %d reaches echo" % (chapter_index + 1))
		_expect(state.visit_echo(Schema.ECHOES[chapter_index]), "chapter %d echo completes" % (chapter_index + 1))
		_expect(state.visit_echo(Schema.ECHOES[chapter_index]), "chapter %d echo retry is idempotent" % (chapter_index + 1))
		_expect(state.is_chapter_completed(chapter_id), "chapter %d is recorded complete" % (chapter_index + 1))
		_expect(state.chapter_progress == "complete", "chapter %d progress is complete" % (chapter_index + 1))
		_expect(
			state.perception_stage == Schema.PERCEPTION_STAGES[chapter_index + 1],
			"chapter %d advances perception" % (chapter_index + 1)
		)
		if chapter_index < Schema.CHAPTERS.size() - 1:
			_expect(
				state.is_chapter_unlocked(Schema.CHAPTERS[chapter_index + 1]),
				"chapter %d unlocks chapter %d" % [chapter_index + 1, chapter_index + 2]
			)

	_expect(state.visited_echoes == Schema.ECHOES, "all five echoes are ordered and unique")
	_expect(state.collected_items.size() == 9, "all nine manuscript items can be collected")
	_expect(item_events.size() == 9, "duplicate collection emits no duplicate event")
	_expect(echo_events == Schema.ECHOES, "duplicate completion emits no duplicate echo event")
	_expect(unlock_events.size() == 4, "exactly four chapter unlock events are emitted")
	_expect(state.chapter_unlocks[Schema.CHAPTERS[-1]] == "complete", "final chapter uses complete marker")
	state.free()


func _test_invalid_operations_are_rejected() -> void:
	var state = _new_state("invalid.json")
	_expect(state.start_new_game(true), "invalid-operation fixture starts")
	var before: Dictionary = state.snapshot()
	_expect(not state.select_chapter(Schema.CHAPTERS[2]), "cannot skip to chapter 3")
	_expect(not state.select_chapter("chapter_unknown"), "unknown chapter is rejected")
	_expect(not state.set_progress("echo"), "progress cannot skip stages")
	_expect(not state.set_progress("complete"), "direct completion is rejected")
	_expect(not state.set_progress("unknown"), "unknown progress is rejected")
	_expect(not state.collect_item("glass_marble"), "future-chapter item is rejected")
	_expect(not state.collect_item("unknown_item"), "unknown item is rejected")
	_expect(not state.visit_echo(Schema.ECHOES[0]), "echo cannot complete before echo stage")
	_expect(not state.complete_chapter(Schema.CHAPTERS[1]), "non-current chapter cannot complete")
	_expect(state.snapshot() == before, "rejected operations leave state untouched")
	state.free()


func _test_save_whitelist_and_round_trip() -> void:
	var path := _test_path("round_trip.json")
	_cleanup_path(path)
	var state = GameStateScript.new()
	state.set_save_path(path)
	_expect(state.start_new_game(true), "round-trip fixture starts")
	_expect(state.collect_item("candy_badge"), "round-trip fixture collects item")
	_expect(state.set_progress("entry"), "round-trip fixture advances")

	var file := FileAccess.open(path, FileAccess.READ)
	_expect(file != null, "save file exists")
	var payload: Variant = JSON.parse_string(file.get_as_text()) if file != null else null
	_expect(typeof(payload) == TYPE_DICTIONARY, "save root is JSON object")
	if typeof(payload) == TYPE_DICTIONARY:
		var payload_dict: Dictionary = payload
		_expect(payload_dict.keys().size() == 2, "save envelope only has version and state")
		_expect(payload_dict.has("saveVersion") and payload_dict.has("state"), "save envelope keys are exact")
		var saved_state: Dictionary = payload_dict.get("state", {})
		var actual_keys: Array = saved_state.keys()
		var expected_keys: Array = Schema.STATE_KEYS.duplicate()
		actual_keys.sort()
		expected_keys.sort()
		_expect(actual_keys == expected_keys, "persisted state uses the six-key whitelist")

	var loaded = GameStateScript.new()
	loaded.set_save_path(path)
	_expect(loaded.load_game(), "valid save loads")
	_expect(loaded.snapshot() == state.snapshot(), "round-trip preserves canonical state")
	state.free()
	loaded.free()


func _test_backup_recovery_and_default_fallback() -> void:
	var path := _test_path("backup_recovery.json")
	_cleanup_path(path)
	var state = GameStateScript.new()
	state.set_save_path(path)
	_expect(state.start_new_game(true), "backup fixture starts")
	_expect(state.collect_item("candy_badge"), "second write creates backup")
	_expect(FileAccess.file_exists(path + ".bak"), "previous valid save is retained as backup")
	_write_raw(path, "{ broken primary")

	var recovered = GameStateScript.new()
	recovered.set_save_path(path)
	_expect(recovered.load_game(), "valid backup is accepted")
	_expect(recovered.last_load_was_recovery, "backup load is marked as recovery")
	_expect(recovered.current_chapter == Schema.CHAPTERS[0], "backup recovery returns valid chapter")
	var restored_result: Dictionary = SaveCodec.decode_text(_read_raw(path))
	_expect(restored_result["ok"], "recovery restores a valid primary save")
	_expect(recovered.clear_save_and_start_new(), "explicit reset writes a new default atomically")
	_expect(recovered.snapshot() == Schema.default_state(), "explicit reset restores canonical defaults")
	_expect(not FileAccess.file_exists(path + ".bak"), "explicit reset removes old-progress backup after success")
	state.free()
	recovered.free()

	var broken_path := _test_path("default_recovery.json")
	_cleanup_path(broken_path)
	_write_raw(broken_path, "not json")
	var fallback = GameStateScript.new()
	fallback.set_save_path(broken_path)
	_expect(not fallback.load_game(), "unrecoverable save reports fallback")
	_expect(fallback.last_load_was_recovery, "default fallback is marked as recovery")
	_expect(fallback.snapshot() == Schema.default_state(), "unrecoverable save falls back to defaults")
	_expect(SaveCodec.decode_text(_read_raw(broken_path))["ok"], "default fallback replaces corrupt primary")
	fallback.free()


func _test_logical_corruption_is_sanitized() -> void:
	var path := _test_path("logical_corruption.json")
	_cleanup_path(path)
	var malicious_state := {
		"currentChapter": Schema.CHAPTERS[4],
		"chapterProgress": "complete",
		"perceptionStage": "ending_echo",
		"collectedItems": ["glass_marble", "glass_marble", "unknown", "candy_badge"],
		"chapterUnlocks": {Schema.CHAPTERS[4]: "complete", "unknown": true},
		"visitedEchoes": [Schema.ECHOES[2], Schema.ECHOES[0], Schema.ECHOES[0]],
		"injectedRuntimeObject": "must be dropped",
	}
	_write_raw(path, JSON.stringify({"saveVersion": 1, "state": malicious_state}))

	var state = GameStateScript.new()
	state.set_save_path(path)
	_expect(state.load_game(), "logically malformed JSON is recoverable through sanitization")
	var clean: Dictionary = state.snapshot()
	_expect(clean.keys().size() == Schema.STATE_KEYS.size(), "sanitized state has exact key count")
	_expect(not clean.has("injectedRuntimeObject"), "unknown state keys are dropped")
	_expect(clean["visitedEchoes"] == [Schema.ECHOES[0]], "out-of-order echo chain is truncated")
	_expect(clean["perceptionStage"] == "chapter_01_echo", "perception is derived from valid echoes")
	_expect(clean["chapterUnlocks"][Schema.CHAPTERS[1]] == true, "valid prior echo unlocks chapter 2")
	_expect(clean["chapterUnlocks"][Schema.CHAPTERS[2]] == false, "invalid echo cannot unlock chapter 3")
	_expect(clean["currentChapter"] == Schema.CHAPTERS[1], "locked requested chapter falls back to latest unlock")
	_expect(clean["chapterProgress"] == "opening", "unearned complete progress is reset")
	_expect(clean["collectedItems"] == ["candy_badge"], "unknown, duplicate, and future items are removed")
	state.free()


func _new_state(file_name: String):
	var path := _test_path(file_name)
	_cleanup_path(path)
	var state = GameStateScript.new()
	state.set_save_path(path)
	return state


func _test_path(file_name: String) -> String:
	return _test_root.path_join(file_name)


func _cleanup_path(path: String) -> void:
	var suffixes: Array[String] = ["", ".bak", ".tmp"]
	for suffix: String in suffixes:
		var candidate: String = path + suffix
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(candidate)


func _write_raw(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(text)
		file.flush()


func _read_raw(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	return file.get_as_text() if file != null else ""


func _occurrences(values: Array, expected: Variant) -> int:
	var count := 0
	for value in values:
		if value == expected:
			count += 1
	return count


func _expect(condition: bool, message: String) -> void:
	_assertion_count += 1
	if not condition:
		_failures.append(message)
