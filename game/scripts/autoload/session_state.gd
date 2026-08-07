extends Node

## Lightweight resume/settings journal kept separate from the canonical story save.
## Puzzle state is intentionally not persisted: returning to a scene restarts that
## scene's short interaction, while completed scene boundaries resume exactly.

const StoryCatalog = preload("res://scripts/content/story_content_catalog.gd")
const SAVE_PATH := "user://me_again/session_v1.json"

signal session_changed

var current_scene_id := ""
var muted := false


func _ready() -> void:
	load_session()


func set_scene(scene_id: String) -> bool:
	if not StoryCatalog.has_scene(scene_id):
		return false
	current_scene_id = scene_id
	_save()
	session_changed.emit()
	return true


func get_resume_scene(chapter_id: String) -> String:
	if not StoryCatalog.has_scene(current_scene_id):
		return StoryCatalog.get_first_scene_id(chapter_id)
	var scene := StoryCatalog.get_scene(current_scene_id)
	if String(scene.get("chapter_id", "")) != chapter_id:
		return StoryCatalog.get_first_scene_id(chapter_id)
	return current_scene_id


func set_muted(value: bool) -> void:
	if muted == value:
		return
	muted = value
	_save()
	session_changed.emit()


func clear_resume() -> void:
	current_scene_id = ""
	_save()
	session_changed.emit()


func load_session() -> void:
	current_scene_id = ""
	muted = false
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	var raw_scene: Variant = data.get("currentScene", "")
	if typeof(raw_scene) == TYPE_STRING and StoryCatalog.has_scene(raw_scene):
		current_scene_id = raw_scene
	var raw_muted: Variant = data.get("muted", false)
	if typeof(raw_muted) == TYPE_BOOL:
		muted = raw_muted


func _save() -> void:
	var base_dir := ProjectSettings.globalize_path("user://me_again")
	DirAccess.make_dir_recursive_absolute(base_dir)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({
		"currentScene": current_scene_id,
		"muted": muted,
	}, "\t"))
