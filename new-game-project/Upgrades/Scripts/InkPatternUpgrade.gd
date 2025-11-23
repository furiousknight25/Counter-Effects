class_name InkPatternUpgrade extends BallUpgrade

@export_enum("Default", "Line", "Circle") var ink_pattern

func do_upgrade():
	SignalBus.emit_signal("upgrade_ball", self)

func upgrade_ball(ball : Ball) -> void:
	ball.ink_pattern = ink_pattern
	
