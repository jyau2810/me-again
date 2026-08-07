extends Node

## Cross-faded music, ambience and pooled one-shot effects.

const MUSIC := {
	"reality": "res://assets/audio/music/reality_calm.mp3",
	"inner": "res://assets/audio/music/inner_world_ambience.mp3",
	"paper": "res://assets/audio/music/musicbox2_cute_tune.ogg",
	"paper_echo": "res://assets/audio/music/musicbox3_sad_tune.ogg",
	"forest": "res://assets/audio/music/forest_exploration.mp3",
	"ending": "res://assets/audio/music/ending_dreamy_loop.ogg",
}

const AMBIENCE := {
	"city": "res://assets/audio/ambience/city_traffic.ogg",
	"rain": "res://assets/audio/ambience/rain_window_loop.wav",
	"wind": "res://assets/audio/ambience/wind_loop.ogg",
}

const SFX := {
	"tap": "res://assets/audio/sfx/switch_01.ogg",
	"success": "res://assets/audio/sfx/switch_02.ogg",
	"paper": "res://assets/audio/sfx/paper_02.ogg",
	"page": "res://assets/audio/sfx/paper_04.ogg",
	"door_open": "res://assets/audio/sfx/door_open.ogg",
	"door_close": "res://assets/audio/sfx/door_close_01.ogg",
	"step": "res://assets/audio/sfx/footstep_03.ogg",
	"glass": "res://assets/audio/sfx/glass_01.ogg",
	"box": "res://assets/audio/sfx/wooded_box_open.ogg",
	"car": "res://assets/audio/sfx/car_pass.wav",
}

var _music_players: Array[AudioStreamPlayer] = []
var _active_music_index := 0
var _ambience_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _music_path := ""
var _ambience_path := ""
var _muted := false
var _music_tween: Tween
var _ambience_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus("Music", -10.0)
	_ensure_bus("Ambience", -15.0)
	_ensure_bus("SFX", -7.0)
	for index in 2:
		var player := AudioStreamPlayer.new()
		player.name = "Music%d" % index
		player.bus = "Music"
		player.volume_db = -60.0 if index == 1 else -12.0
		add_child(player)
		_music_players.append(player)
	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.name = "Ambience"
	_ambience_player.bus = "Ambience"
	_ambience_player.volume_db = -16.0
	add_child(_ambience_player)
	for index in 8:
		var player := AudioStreamPlayer.new()
		player.name = "Sfx%d" % index
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)


func _exit_tree() -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	if _ambience_tween != null and _ambience_tween.is_valid():
		_ambience_tween.kill()
	for player in _music_players:
		player.stop()
		player.stream = null
	if _ambience_player != null:
		_ambience_player.stop()
		_ambience_player.stream = null
	for player in _sfx_players:
		player.stop()
		player.stream = null


func set_muted(value: bool) -> void:
	_muted = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), value)


func is_muted() -> bool:
	return _muted


func set_scene(chapter_id: String, phase: String, scene_id: String) -> void:
	# CI/headless smoke runs have no audible output and some macOS audio drivers
	# retain a playback object during forced `--quit-after`; skip decoding there.
	if DisplayServer.get_name() == "headless":
		return
	var music_key := "reality"
	if chapter_id == "03_paper_friends":
		music_key = "paper_echo" if phase == "echo" else "paper"
	elif chapter_id == "05_after_forest":
		music_key = "ending" if phase == "echo" else "forest"
	elif phase == "entry" or phase == "inner_world":
		music_key = "inner"
	_crossfade_music(MUSIC[music_key])

	var ambience_key := ""
	if chapter_id == "01_grey_morning":
		ambience_key = "city"
	elif chapter_id == "04_cabinet_breath":
		ambience_key = "rain"
	elif chapter_id == "05_after_forest" or scene_id.contains("forest"):
		ambience_key = "wind"
	_set_ambience(AMBIENCE.get(ambience_key, ""))


func play_sfx(kind: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var path: String = SFX.get(kind, SFX["tap"])
	var stream := load(path) as AudioStream
	if stream == null:
		return
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = randf_range(0.97, 1.03)
			player.play()
			return
	_sfx_players[0].stream = stream
	_sfx_players[0].play()


func _crossfade_music(path: String) -> void:
	if path.is_empty() or path == _music_path:
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	stream.set("loop", true)
	var previous := _music_players[_active_music_index]
	_active_music_index = 1 - _active_music_index
	var incoming := _music_players[_active_music_index]
	incoming.stream = stream
	incoming.volume_db = -60.0
	incoming.play()
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = create_tween().set_parallel(true)
	_music_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_music_tween.tween_property(incoming, "volume_db", -12.0, 1.8)
	_music_tween.tween_property(previous, "volume_db", -60.0, 1.8)
	_music_tween.chain().tween_callback(previous.stop)
	_music_path = path


func _set_ambience(path: String) -> void:
	if path == _ambience_path:
		return
	if _ambience_tween != null and _ambience_tween.is_valid():
		_ambience_tween.kill()
	_ambience_tween = create_tween()
	_ambience_tween.tween_property(_ambience_player, "volume_db", -60.0, 0.55)
	await _ambience_tween.finished
	_ambience_player.stop()
	_ambience_path = path
	if path.is_empty():
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	stream.set("loop", true)
	_ambience_player.stream = stream
	_ambience_player.volume_db = -60.0
	_ambience_player.play()
	_ambience_tween = create_tween()
	_ambience_tween.tween_property(_ambience_player, "volume_db", -17.0, 1.2)


func _ensure_bus(bus_name: String, volume_db: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		AudioServer.add_bus()
		index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_volume_db(index, volume_db)
