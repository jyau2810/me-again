extends RefCounted
class_name MeGameSchema

## Canonical five-chapter state schema.
##
## This is deliberately the only place that knows chapter order, echo IDs, item
## ownership, and perception progression. Save data is treated as untrusted input
## and is normalized through [method sanitize_state] before it reaches gameplay.

const STATE_KEYS: Array[String] = [
	"currentChapter",
	"chapterProgress",
	"perceptionStage",
	"collectedItems",
	"chapterUnlocks",
	"visitedEchoes",
]

const CHAPTERS: Array[String] = [
	"01_grey_morning",
	"02_looping_school",
	"03_paper_friends",
	"04_cabinet_breath",
	"05_after_forest",
]

const PROGRESS_STAGES: Array[String] = [
	"opening",
	"entry",
	"inner_world",
	"echo",
	"complete",
]

const PERCEPTION_STAGES: Array[String] = [
	"opening",
	"chapter_01_echo",
	"chapter_02_echo",
	"chapter_03_echo",
	"chapter_04_echo",
	"ending_echo",
]

const ECHOES: Array[String] = [
	"c01_commute_echo",
	"c02_room_corner_echo",
	"c03_new_book_echo",
	"c04_quiet_room_echo",
	"c05_morning_echo",
]

const ITEMS_BY_CHAPTER: Dictionary = {
	"01_grey_morning": ["candy_badge"],
	"02_looping_school": ["eraser_crumb", "half_chalk", "sticker_star"],
	"03_paper_friends": ["character_sticker", "old_bookmark"],
	"04_cabinet_breath": ["plastic_ruler"],
	"05_after_forest": ["glass_marble", "impossible_fossil"],
}


static func default_state() -> Dictionary:
	return {
		"currentChapter": CHAPTERS[0],
		"chapterProgress": PROGRESS_STAGES[0],
		"perceptionStage": PERCEPTION_STAGES[0],
		"collectedItems": [],
		"chapterUnlocks": _unlocks_for_completed_count(0),
		"visitedEchoes": [],
	}


static func sanitize_state(raw_state: Variant) -> Dictionary:
	if typeof(raw_state) != TYPE_DICTIONARY:
		return default_state()

	var raw: Dictionary = raw_state
	var visited_echoes := _sanitize_echo_chain(raw.get("visitedEchoes", []))
	var completed_count := visited_echoes.size()
	var chapter_unlocks := _unlocks_for_completed_count(completed_count)
	var highest_unlocked_index := mini(completed_count, CHAPTERS.size() - 1)

	var current_chapter: String = _latest_unlocked_chapter(chapter_unlocks)
	var raw_chapter: Variant = raw.get("currentChapter", "")
	if typeof(raw_chapter) == TYPE_STRING:
		var requested_chapter: String = raw_chapter
		if is_chapter_id(requested_chapter) and is_unlock_value_open(chapter_unlocks[requested_chapter]):
			current_chapter = requested_chapter

	var chapter_progress := PROGRESS_STAGES[0]
	var raw_progress: Variant = raw.get("chapterProgress", "")
	if typeof(raw_progress) == TYPE_STRING and PROGRESS_STAGES.has(raw_progress):
		chapter_progress = raw_progress

	# A `complete` progress marker is only valid when the matching chapter echo is
	# present. This closes the only route by which a hand-edited save could claim a
	# completion without advancing the canonical echo chain.
	var current_index := chapter_index(current_chapter)
	if chapter_progress == "complete" and not visited_echoes.has(ECHOES[current_index]):
		chapter_progress = "opening"

	var collected_items := _sanitize_items(
		raw.get("collectedItems", []),
		highest_unlocked_index
	)

	return {
		"currentChapter": current_chapter,
		"chapterProgress": chapter_progress,
		"perceptionStage": PERCEPTION_STAGES[completed_count],
		"collectedItems": collected_items,
		"chapterUnlocks": chapter_unlocks,
		"visitedEchoes": visited_echoes,
	}


static func is_chapter_id(chapter_id: String) -> bool:
	return CHAPTERS.has(chapter_id)


static func is_item_id(item_id: String) -> bool:
	return chapter_for_item(item_id) != ""


static func is_echo_id(echo_id: String) -> bool:
	return ECHOES.has(echo_id)


static func chapter_index(chapter_id: String) -> int:
	return CHAPTERS.find(chapter_id)


static func chapter_for_item(item_id: String) -> String:
	for chapter_id in CHAPTERS:
		var items: Array = ITEMS_BY_CHAPTER[chapter_id]
		if items.has(item_id):
			return chapter_id
	return ""


static func echo_for_chapter(chapter_id: String) -> String:
	var index := chapter_index(chapter_id)
	if index < 0:
		return ""
	return ECHOES[index]


static func next_chapter(chapter_id: String) -> String:
	var index := chapter_index(chapter_id)
	if index < 0 or index >= CHAPTERS.size() - 1:
		return ""
	return CHAPTERS[index + 1]


static func is_unlock_value_open(value: Variant) -> bool:
	if typeof(value) == TYPE_BOOL:
		return value
	if typeof(value) == TYPE_STRING:
		return value == "complete"
	return false


static func _sanitize_echo_chain(raw_echoes: Variant) -> Array[String]:
	var result: Array[String] = []
	if typeof(raw_echoes) != TYPE_ARRAY:
		return result

	# Only the longest contiguous prefix is accepted. `c03_*` without both prior
	# echoes is corruption, not an alternate progression path.
	for expected_echo in ECHOES:
		if raw_echoes.has(expected_echo):
			result.append(expected_echo)
		else:
			break
	return result


static func _sanitize_items(raw_items: Variant, highest_unlocked_index: int) -> Array[String]:
	var result: Array[String] = []
	if typeof(raw_items) != TYPE_ARRAY:
		return result

	for value in raw_items:
		if typeof(value) != TYPE_STRING:
			continue
		var item_id: String = value
		var owner_chapter := chapter_for_item(item_id)
		if owner_chapter == "":
			continue
		if chapter_index(owner_chapter) > highest_unlocked_index:
			continue
		if not result.has(item_id):
			result.append(item_id)
	return result


static func _unlocks_for_completed_count(completed_count: int) -> Dictionary:
	var result := {}
	var highest_unlocked_index := mini(completed_count, CHAPTERS.size() - 1)
	for index in CHAPTERS.size():
		result[CHAPTERS[index]] = index <= highest_unlocked_index

	if completed_count >= CHAPTERS.size():
		# The manuscript explicitly uses `complete` for the final chapter marker.
		result[CHAPTERS[-1]] = "complete"
	return result


static func _latest_unlocked_chapter(chapter_unlocks: Dictionary) -> String:
	var result := CHAPTERS[0]
	for chapter_id in CHAPTERS:
		if is_unlock_value_open(chapter_unlocks.get(chapter_id, false)):
			result = chapter_id
	return result
