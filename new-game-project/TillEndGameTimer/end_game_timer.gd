extends Timer
@onready var progress_bar: ProgressBar = $ProgressBar

signal game_end
func _on_timeout(): emit_signal("game_end")

func _process(delta: float) -> void:
	progress_bar.value = lerp(0.0,100.0, time_left/wait_time)
