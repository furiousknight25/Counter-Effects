class_name BiggerBall extends BallUpgrade

@export var new_scale : float = 1.0

func do_upgrade():
	SignalBus.emit_signal("upgrade_ball", self)

func upgrade_ball(ball : Ball) -> void:
	ball.scale = Vector2(new_scale, new_scale)
