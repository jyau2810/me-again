extends Node

## Project-wide state and persistence boundary.
##
## Gameplay code should use the methods on this singleton instead of mutating a
## Dictionary. Every write is validated, automatically persisted, and emitted as
## a snapshot so scene code never receives a mutable reference to internal state.

const Schema = preload("res://scripts/domain/game_schema.gd")
const SaveCodec = preload("res://scripts/domain/save_codec.gd")
const DEFAULT_SAVE_PATH := "user://me_again/save_v1.json"

signal state_changed(state: Dictionary)
signal item_collected(item_id: String)
signal echo_visited(echo_id: String)
signal chapter_unlocked(chapter_id: String)
signal chapter_completed(chapter_id: String)
signal save_failed(reason: String)
signal save_recovered(source_path: String)

var autosave_enabled := true
var last_load_was_recovery := false
var last_error := ""

var _save_path := DEFAULT_SAVE_PATH
var _state: Dictionary = Schema.default_state()

var current_chapter: String:
	get:
		return _state["currentChapter"]

var chapter_progress: String:
	get:
		return _state["chapterProgress"]

var perception_stage: String:
	get:
		return _state["perceptionStage"]

var collected_items: Array:
	get:
		return _state["collectedItems"].duplicate()

var chapter_unlocks: Dictionary:
	get:
		return _state["chapterUnlocks"].duplicate(true)

var visited_echoes: Array:
	get:
		return _state["visitedEchoes"].duplicate()


func _ready() -> void:
	load_game()


func snapshot() -> Dictionary:
	return _state.duplicate(true)


func get_save_path() -> String:
	return _save_path


func set_save_path(path: String) -> bool:
	if path.strip_edges().is_empty():
		return false
	_save_path = path
	return true


func start_new_game(persist := true) -> bool:
	var previous_state := _state
	_state = Schema.default_state()
	if persist and not save_game():
		_state = previous_state
		return false
	last_load_was_recovery = false
	last_error = ""
	state_changed.emit(snapshot())
	return true


func clear_save_and_start_new() -> bool:
	# Let the atomic writer rotate the old primary first, so a failed reset never
	# destroys the only valid save. Remove that backup only after the new default
	# state is safely promoted.
	if not start_new_game(true):
		return false
	_remove_if_present(_absolute_path(_save_path) + ".bak")
	return true


func select_chapter(chapter_id: String) -> bool:
	if not Schema.is_chapter_id(chapter_id) or not is_chapter_unlocked(chapter_id):
		return false

	var next_state := snapshot()
	next_state["currentChapter"] = chapter_id
	next_state["chapterProgress"] = "opening"
	return _commit(next_state)


func set_progress(next_progress: String) -> bool:
	if not Schema.PROGRESS_STAGES.has(next_progress):
		return false

	var current_index: int = Schema.PROGRESS_STAGES.find(chapter_progress)
	var next_index: int = Schema.PROGRESS_STAGES.find(next_progress)
	if current_index == next_index:
		return true
	if next_progress == "complete":
		# Completion is a multi-field transaction; use complete_chapter().
		return false
	if next_index != current_index + 1:
		return false

	var next_state := snapshot()
	next_state["chapterProgress"] = next_progress
	return _commit(next_state)


func collect_item(item_id: String) -> bool:
	if not Schema.is_item_id(item_id):
		return false
	if Schema.chapter_for_item(item_id) != current_chapter:
		return false
	if _state["collectedItems"].has(item_id):
		return true

	var next_state := snapshot()
	var items: Array = next_state["collectedItems"]
	items.append(item_id)
	if not _commit(next_state):
		return false
	item_collected.emit(item_id)
	return true


func has_item(item_id: String) -> bool:
	return _state["collectedItems"].has(item_id)


func visit_echo(echo_id: String) -> bool:
	if not Schema.is_echo_id(echo_id):
		return false
	if Schema.echo_for_chapter(current_chapter) != echo_id:
		return false
	return complete_chapter(current_chapter)


func complete_chapter(chapter_id: String) -> bool:
	if not Schema.is_chapter_id(chapter_id) or chapter_id != current_chapter:
		return false

	var echo_id: String = Schema.echo_for_chapter(chapter_id)
	var already_visited: bool = _state["visitedEchoes"].has(echo_id)
	if already_visited:
		if chapter_progress == "complete":
			return true
		# A replay may finish again, but it cannot emit another echo or unlock event.
		if chapter_progress != "echo":
			return false
		var replay_state := snapshot()
		replay_state["chapterProgress"] = "complete"
		return _commit(replay_state)

	if chapter_progress != "echo":
		return false

	var next_chapter_id: String = Schema.next_chapter(chapter_id)
	var was_next_locked := (
		not next_chapter_id.is_empty()
		and not is_chapter_unlocked(next_chapter_id)
	)
	var next_state := snapshot()
	next_state["chapterProgress"] = "complete"
	var echoes: Array = next_state["visitedEchoes"]
	echoes.append(echo_id)

	if not _commit(next_state):
		return false

	echo_visited.emit(echo_id)
	chapter_completed.emit(chapter_id)
	if was_next_locked and is_chapter_unlocked(next_chapter_id):
		chapter_unlocked.emit(next_chapter_id)
	return true


func is_chapter_unlocked(chapter_id: String) -> bool:
	if not Schema.is_chapter_id(chapter_id):
		return false
	return Schema.is_unlock_value_open(_state["chapterUnlocks"].get(chapter_id, false))


func is_chapter_completed(chapter_id: String) -> bool:
	if not Schema.is_chapter_id(chapter_id):
		return false
	return _state["visitedEchoes"].has(Schema.echo_for_chapter(chapter_id))


func save_game() -> bool:
	var encoded := SaveCodec.encode_state(_state)
	if _write_atomic(encoded):
		last_error = ""
		return true
	if last_error.is_empty():
		last_error = "failed to write save"
	save_failed.emit(last_error)
	return false


func load_game() -> bool:
	last_load_was_recovery = false
	last_error = ""
	var primary_path := _absolute_path(_save_path)
	var backup_path := primary_path + ".bak"
	var primary_exists := FileAccess.file_exists(primary_path)
	var backup_exists := FileAccess.file_exists(backup_path)

	if primary_exists:
		var primary_result := _decode_file(primary_path)
		if primary_result["ok"]:
			_state = primary_result["state"]
			if primary_result["requiresRewrite"]:
				save_game()
			state_changed.emit(snapshot())
			return true
		last_error = primary_result["error"]

	if backup_exists:
		var backup_result := _decode_file(backup_path)
		if backup_result["ok"]:
			_state = backup_result["state"]
			last_load_was_recovery = true
			# Restore the primary directly while leaving the known-good backup intact.
			_remove_if_present(primary_path)
			if not _write_direct(primary_path, SaveCodec.encode_state(_state)):
				save_failed.emit(last_error)
			state_changed.emit(snapshot())
			save_recovered.emit(backup_path)
			return true
		if last_error.is_empty():
			last_error = backup_result["error"]

	# A missing save is a normal first launch. A present-but-unreadable save is a
	# recovery event and is replaced with a known-good default.
	last_load_was_recovery = primary_exists or backup_exists
	_state = Schema.default_state()
	_remove_if_present(primary_path)
	_remove_if_present(backup_path)
	# The safe in-memory default remains usable even if persistence is currently
	# unavailable; save_game() emits save_failed in that case.
	save_game()
	state_changed.emit(snapshot())
	if last_load_was_recovery:
		save_recovered.emit("defaults")
	return false


func _commit(candidate_state: Dictionary) -> bool:
	var canonical_state: Dictionary = Schema.sanitize_state(candidate_state)
	if canonical_state == _state:
		return true

	var previous_state := _state
	_state = canonical_state
	if autosave_enabled and not save_game():
		_state = previous_state
		return false
	state_changed.emit(snapshot())
	return true


func _decode_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {
			"ok": false,
			"state": Schema.default_state(),
			"error": "cannot open save: %s" % error_string(FileAccess.get_open_error()),
			"requiresRewrite": false,
		}
	return SaveCodec.decode_text(file.get_as_text())


func _write_atomic(text: String) -> bool:
	var primary_path := _absolute_path(_save_path)
	var temporary_path := primary_path + ".tmp"
	var backup_path := primary_path + ".bak"
	if not _ensure_parent_directory(primary_path):
		return false

	_remove_if_present(temporary_path)
	if not _write_direct(temporary_path, text):
		return false

	_remove_if_present(backup_path)
	var moved_primary := false
	if FileAccess.file_exists(primary_path):
		var backup_error := DirAccess.rename_absolute(primary_path, backup_path)
		if backup_error != OK:
			last_error = "cannot rotate save: %s" % error_string(backup_error)
			_remove_if_present(temporary_path)
			return false
		moved_primary = true

	var promote_error := DirAccess.rename_absolute(temporary_path, primary_path)
	if promote_error == OK:
		return true

	last_error = "cannot promote temporary save: %s" % error_string(promote_error)
	if moved_primary and FileAccess.file_exists(backup_path):
		DirAccess.rename_absolute(backup_path, primary_path)
	_remove_if_present(temporary_path)
	return false


func _write_direct(path: String, text: String) -> bool:
	if not _ensure_parent_directory(path):
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		last_error = "cannot open save for writing: %s" % error_string(FileAccess.get_open_error())
		return false
	file.store_string(text)
	file.flush()
	var write_error := file.get_error()
	if write_error != OK:
		last_error = "cannot flush save: %s" % error_string(write_error)
		return false
	return true


func _ensure_parent_directory(path: String) -> bool:
	var parent := path.get_base_dir()
	var directory_error := DirAccess.make_dir_recursive_absolute(parent)
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		last_error = "cannot create save directory: %s" % error_string(directory_error)
		return false
	return true


func _absolute_path(path: String) -> String:
	return ProjectSettings.globalize_path(path)


func _remove_if_present(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
