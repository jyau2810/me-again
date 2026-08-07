extends SceneTree

const StoryCatalog = preload("res://scripts/content/story_content_catalog.gd")


func _initialize() -> void:
	var errors := StoryCatalog.validate_catalog()
	if errors.is_empty():
		print("Story content catalog OK: %d chapters, %d scenes, %d collectibles." % [
			StoryCatalog.CHAPTERS.size(),
			StoryCatalog.SCENES.size(),
			StoryCatalog.COLLECTIBLES.size(),
		])
		quit(0)
		return

	for error in errors:
		push_error(error)
	quit(1)
