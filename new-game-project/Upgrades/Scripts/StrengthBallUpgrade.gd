class_name StrengthBallUpgrade extends BallUpgrade

@export var strength : float = 50.0

func do_upgrade() -> void:
	SignalBus.emit_signal("upgrade_ball", self)


func upgrade_ball(ball : Ball) -> void:
	ball.strength += strength
