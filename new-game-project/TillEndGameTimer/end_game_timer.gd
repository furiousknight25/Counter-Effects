extends Timer
@onready var progress_bar: ProgressBar = $ProgressBar

var round_start : bool = false

func _on_timeout():
	Music.transition_to_shop()

func _process(_delta: float) -> void:
	if round_start == true:
		progress_bar.value = lerp(0.0,100.0, time_left/wait_time)
	
	if Input.is_action_just_pressed("ui_right"): 
		start(.2)
		wait_time = 20.0

func _ready() -> void:
	SignalBus.connect("reset", reset)
	SignalBus.connect("ball_hit", start_round)


func reset() -> void:
	round_start = false
	progress_bar.value = 100
	stop()


func start_round() -> void:
	if round_start == true:
		return
	start()
	round_start = true
