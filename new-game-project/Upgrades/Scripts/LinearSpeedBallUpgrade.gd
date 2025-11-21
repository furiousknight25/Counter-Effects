class_name LinearSpeedBallUpgrade extends BallUpgrade

func do_upgrade():
	SignalBus.emit_signal("upgrade_ball", self)

func upgrade_ball(ball : Ball) -> void:
	ball.linear_speed_increase = true
