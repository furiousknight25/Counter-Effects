extends Node
class_name AdaptiveMusic

@export var tracks : Array[AudioStreamPlayer]
@export var bpm: float = 159.0

@onready var progress_bar: ProgressBar = $UI/ProgressBar
@onready var master_track = tracks[0]

var beat_duration: float # per second number
func _ready() -> void:
	beat_duration = 60.0 /bpm
	start()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		increase_volume(0, -10.0, .01)
	if Input.is_action_just_pressed("2"):
		increase_volume(1, -10.0, .01)
	if Input.is_action_just_pressed("3"):
		increase_volume(2, -10.0, .01)
	if Input.is_action_just_pressed("4"):
		increase_volume(3, -10.0, .01)
	if Input.is_action_just_pressed("5"):
		increase_volume(0, -80.0, .5)
		increase_volume(1, -80.0, .5)
		increase_volume(2, -80.0, .5)
		increase_volume(3, -80.0, .5)

func start():
	for i in tracks:
		i.play()
	
	master_track = tracks[0]
	
	await master_track.ready
	
	var measure_duration = 4.0 * beat_duration #assuming 4/4 time
	var current_time = master_track.get_playback_position()
	var sync_time = fmod(current_time, measure_duration)
	
	for i in range(1, tracks.size()):
		var follower_track = tracks[i]
		follower_track.seek(sync_time)

func increase_volume(idx: int, volume : float, fade_duration: float):
	if idx >= tracks.size(): 
		print("AINT NO DAMN TRACK EXISTS")
		return
	
	var current_time = master_track.get_playback_position()
	var measure_duration = 4.0 * beat_duration * 4
	
	var time_untill_sync = measure_duration - fmod(current_time, measure_duration)
	
	var tween_bar = get_tree().create_tween()
	tween_bar.tween_property(progress_bar, "value", 100.0, time_untill_sync) #debug
	
	print(time_untill_sync)
	await tween_bar.finished
	var tween = get_tree().create_tween()
	tween.tween_property(tracks[idx], "volume_db", volume, fade_duration)
	var final_pos = progress_bar.position
	progress_bar.position.y += 5
	
	var twee = get_tree().create_tween().tween_property(progress_bar,'position', final_pos, 1.0).set_trans(tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	var fina_rot = progress_bar.rotation
	progress_bar.rotation += .05
	var twee2 = get_tree().create_tween().tween_property(progress_bar,'rotation', fina_rot, 2.0).set_trans(tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	progress_bar.value = 0.0
