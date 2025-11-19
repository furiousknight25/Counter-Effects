extends Node

@onready var transition_manager: TransitionManager = $TransitionManager
@onready var upgrade_array : Array[Upgrade]
@onready var level_1: Node2D = $"Level 1"

func _ready() -> void:
	SignalBus.connect("switch_scene", switch_scene)


func switch_scene(old_scene : Node2D, new_scene : PackedScene):
	var new_instanced_scene : Node2D = new_scene.instantiate()
	new_instanced_scene.position.x = 280
	add_child.call_deferred(new_instanced_scene)
	
	transition_manager.node1 = old_scene
	transition_manager.node2 = new_instanced_scene
	
	transition_manager.transition_scenes()
	await transition_manager.transition_finished
	
	old_scene.queue_free()
	


func add_upgrade_to_array(upgrade : Upgrade):
	upgrade_array.append(upgrade)
