class_name GameStateManager extends Node

var level_idx : int = 0
@export var scenes : Dictionary[String, PackedScene]
@onready var transition_manager: TransitionManager = $TransitionManager
@onready var upgrade_array : Array[Upgrade]
@onready var active_level: Level = $"Level_1"
@onready var ball: Ball = $Ball
@onready var player: Player = %Player
@onready var ui: Control = $UI

func _ready() -> void:
	SignalBus.connect("switch_scene", switch_scene)

func switch_scene(old_scene : Level, new_scene : Level):
	new_scene.position.x = 280
	add_child.call_deferred(new_scene)
	SignalBus.emit_signal("resetInking", new_scene.starting_image)
	transition_manager.node1 = old_scene
	transition_manager.node2 = new_scene
	
	transition_manager.transition_scenes()
	await transition_manager.transition_finished
	old_scene.queue_free()
	player.visible = true
	ball.visible = true
	active_level = new_scene
	ui.show()

func add_upgrade_to_array(upgrade : Upgrade):
	upgrade_array.append(upgrade)


func call_switch_scene(location : String):
	ui.hide()
	var loaded_scene : Level
	player.visible = false
	ball.visible = false
	match location:
		"next_level":
			level_idx += 1
			loaded_scene = scenes.get(str(level_idx)).instantiate()
		"Shop":
			loaded_scene = scenes.get('shop').instantiate()
			player.position = Vector2(32, 157)
			ball.position = Vector2(-10, -10)
		"Level_1":
			loaded_scene = scenes.get('1').instantiate()
			player.position = Vector2(32, 157)
			ball.position = Vector2(128, 112)
	add_child(loaded_scene)
	SignalBus.emit_signal("switch_scene", active_level, loaded_scene)
	# need to update active level somewhere in here
	get_tree().paused = true #oh this is probalbly pausing music
