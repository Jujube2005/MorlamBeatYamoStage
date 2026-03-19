extends Node2D

@export var bpm: float = 100.0
@export var fk_fall_time: float = 2.2
@export var subdivision: int = 2
@export var offset: float = 0.0  
var is_playing: bool = true

var current_level_name = "RHYTHM_HELL"

# TIME SYSTEM
var time_begin
var time_delay
var beat_accumulator: float = 0.0

# LEVEL DATA
var level_info = {
	"RHYTHM_HELL" = {
		"music": load("res://music/Mor Lam.mp3")
	}
}

# READY
func _ready():
	$MusicPlayer.stream = level_info[current_level_name]["music"]
	$MusicPlayer.play()
	is_playing = true

	# 🎯 Sync เวลาเพลงแบบแม่น
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()

# GET MUSIC TIME
func get_music_time():
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	time -= time_delay
	return max(0, time)

# AUTO BPM SPAWN
func _process(delta):
	if !is_playing:
		return

	var music_time = get_music_time()
	var seconds_per_step = (60.0 / bpm) / subdivision

	var target_time = music_time + fk_fall_time + offset

	while beat_accumulator * seconds_per_step < target_time:
		spawn_note_pattern(int(beat_accumulator))
		beat_accumulator += 1

# SPAWN PATTERN
func spawn_note_pattern(step: int):
	var keys = ["button_Q", "button_W", "button_E", "button_R"]

	if step % (4 * subdivision) == 0:
		Signals.CreateFallingKey.emit(keys.pick_random())

	elif randf() < 0.2:
		Signals.CreateFallingKey.emit(keys.pick_random())

func _on_music_player_finished() -> void:
	is_playing = false
