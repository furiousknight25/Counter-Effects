extends Node

@onready var upgrade_array : Array[Upgrade]

func _ready() -> void:
	SignalBus.connect("switch_scene", switch_scene)


func switch_scene(old_scene : Node2D, new_scene : PackedScene):
	old_scene.queue_free()
	add_child(new_scene.instantiate())


func add_upgrade_to_array(upgrade : Upgrade):
	upgrade_array.append(upgrade)
