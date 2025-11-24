class_name BiggerBall extends BallUpgrade

func do_upgrade():
	SignalBus.emit_signal("upgrade_ball", self)

func upgrade_ball(ball : Ball) -> void:
	ball.scale = Vector2(2, 2)
