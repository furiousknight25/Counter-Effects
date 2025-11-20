extends Timer
@onready var progress_bar: ProgressBar = $ProgressBar

var round_start : bool = false

signal game_end
func _on_timeout(): emit_signal("game_end")

func _process(_delta: float) -> void:
	if round_start == true:
		progress_bar.value = lerp(0.0,100.0, time_left/wait_time)

func _ready() -> void:
	SignalBus.connect("resetInking", reset)
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
