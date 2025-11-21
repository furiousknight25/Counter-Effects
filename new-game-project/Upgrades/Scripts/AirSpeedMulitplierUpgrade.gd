class_name AirSpeedMultiplier extends PlayerUpgrade

@export var airspeed_mult : float = 1.0

func do_upgrade():
	SignalBus.emit_signal("upgrade_player", self)


func upgrade_player(player : Player) -> void:
	player.airspeed_multiplier = airspeed_mult
