class_name GameStateManager extends Node

@onready var player: Player = %Player
@onready var upgrade_array : Array[Upgrade]


func upgrade_player():
	for upgrade in upgrade_array:
		if upgrade is PlayerUpgrade:
			upgrade.upgrade_player(player)
