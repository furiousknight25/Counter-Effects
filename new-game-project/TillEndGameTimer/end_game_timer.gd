extends Timer

signal game_end
func timer_end():
	
	emit_signal("game_end")
