class_name GameStateManager extends Node

@onready var transition_manager: TransitionManager = $TransitionManager
@onready var upgrade_array : Array[Upgrade]
@onready var active_level: Node2D = $"Level_1"
@onready var ball: Ball = $Ball
@onready var player: Player = %Player
@onready var ui: Control = $UI

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
	player.visible = true
	ball.visible = true
	active_level = new_instanced_scene
	ui.show()


func add_upgrade_to_array(upgrade : Upgrade):
	upgrade_array.append(upgrade)


func call_switch_scene(location : String):
	ui.hide()
	var loaded_scene
	player.visible = false
	ball.visible = false
	match location:
		"Shop":
			loaded_scene = load("res://Levels/Level Scenes/shop.tscn")
			player.position = Vector2(32, 157)
			ball.position = Vector2(-10, -10)
		"Level_1":
			loaded_scene = load("res://Levels/Level Scenes/Level_1.tscn")
			player.position = Vector2(32, 157)
			ball.position = Vector2(128, 112)
			
	SignalBus.emit_signal("switch_scene", active_level, loaded_scene)
	# need to update active level somewhere in here
	get_tree().paused = true
	
