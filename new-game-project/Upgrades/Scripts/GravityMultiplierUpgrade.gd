class_name GravityMultiplier extends PlayerUpgrade

@export var gravity_multiplier : float = 1.0


func do_upgrade():
	SignalBus.emit_signal("upgrade_player", self )


func upgrade_player(player : Player) -> void:
	player.gravity *= gravity_multiplier
	print(player.gravity )
