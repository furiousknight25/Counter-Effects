class_name PlayerHealthUpgrade extends PlayerUpgrade

@export var health_modifier : int = 0

func upgrade_player(player : Player) -> void:
	print("change player health by" + str(health_modifier))
	player.set_health(player.get_health() + health_modifier)
