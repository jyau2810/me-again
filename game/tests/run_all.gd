extends SceneTree

const GameStateTests = preload("res://tests/test_game_state.gd")


func _initialize() -> void:
	var suite = GameStateTests.new()
	var result: Dictionary = suite.run()
	var failures: Array = result["failures"]

	if failures.is_empty():
		print("PASS: %d assertions" % result["assertions"])
		quit(0)
		return

	printerr("FAIL: %d of %d assertions failed" % [failures.size(), result["assertions"]])
	for failure in failures:
		printerr("  - %s" % failure)
	quit(1)
