extends Level

@onready var upgrades: Node = $Upgrades
@onready var buy: AudioStreamPlayer = $buy

func _ready() -> void:
	set_all_upgrade_items()
	
	SignalBus.connect("upgrade_taken", add_to_taken)


func set_all_upgrade_items():
	for upgrade_item : UpgradeItem in upgrades.get_children():
		var upgrade_key : String = upgrade_item.upgrades_dict.keys().pick_random()
		
		while is_in_taken(upgrade_key) == true:
			upgrade_key = upgrade_item.upgrades_dict.keys().pick_random()
		upgrade_item.set_upgrade(upgrade_key)
	

func add_to_taken(upgrade_name : String):
	Music.move_up('shop')
	$AnimationPlayer.play("thankyou")
	$buy.play()
	(get_parent() as GameStateManager).taken_upgrades.append(upgrade_name)


func is_in_taken(upgrade_name : String) -> bool:
	if (get_parent() as GameStateManager).taken_upgrades.has(upgrade_name):
		return true
	else:
		return false
	
