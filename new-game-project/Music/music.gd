extends Node

signal current_beat
signal current_bar
signal current_four_bar
signal current_eight_bar

@export var song_list : Dictionary[String, AdaptiveMusic]
var last_beat_index: int = 0
var bar_index: int = 0

var current_song : AdaptiveMusic

func _ready() -> void:
	current_song = song_list.get('openyourmind')
	current_song.start()

func switch_song(song : String):
	await current_eight_bar
	var time_to_start = current_song.master_track.get_playback_position()
	current_song.stop()
	match song:
		"shop":
			current_song = song_list.get('shop')
		"glob":
			current_song = song_list.get('glob')
		"openyourmind":
			current_song = song_list.get('openyourmind')
	current_song.start(time_to_start)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):switch_song("shop")
	if !current_song.master_track.playing: return
	var current_beat_index = int(current_song.master_track.get_playback_position() / current_song.beat_duration)
	
	if current_beat_index > last_beat_index or current_beat_index == 0 and last_beat_index > current_beat_index:
		emit_signal("current_beat")
		last_beat_index = current_beat_index
		bar_index += 1
		if bar_index % 4 == 0: emit_signal("current_bar")
		if bar_index % (4 * 4) == 0:emit_signal("current_four_bar")
		if bar_index % (4 * 4 * 2) == 0:emit_signal("current_eight_bar")
