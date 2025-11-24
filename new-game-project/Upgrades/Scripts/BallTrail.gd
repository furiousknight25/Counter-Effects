class_name BallTrail extends BallUpgrade

func do_upgrade():
	SignalBus.emit_signal("upgrade_ball", self)
	
func upgrade_ball(ball : Ball) -> void:
	ball.has_trail = true
