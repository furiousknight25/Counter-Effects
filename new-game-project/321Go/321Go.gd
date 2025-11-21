extends Control
@onready var _3: Label = $"3"
@onready var _2: Label = $"2"
@onready var _1: Label = $"1"
@onready var go: Label = $GO
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var playing = -1
func _ready() -> void:
	Music.connect("current_beat", beat_hit)

func _process(delta: float) -> void: if Input.is_action_pressed("ui_up"):  start_countdown()

func start_countdown():
	await Music.current_four_bar
	playing = 0

func beat_hit():
	$Polygon2D.visible = !$Polygon2D.visible
	
	match playing:
		0:
			_3.show()
			playing += 1
			audio_stream_player.play()
			audio_stream_player.pitch_scale = 1.2
		1:
			_2.show()
			playing += 1
			audio_stream_player.play()
		2:
			_1.show()
			playing += 1
			audio_stream_player.play()
		3:
			playing += 1
			_3.hide()
			_2.hide()
			_1.hide()
			go.show()
			audio_stream_player.play()
			audio_stream_player.pitch_scale = .5
		4:
			playing += 1
		5:
			go.hide()
			playing = -1
