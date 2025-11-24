class_name GameStateManager extends Node

var level_idx : int = 0
@export var scenes : Dictionary[String, PackedScene]
@onready var transition_manager: TransitionManager = $TransitionManager
@onready var upgrade_array : Array[Upgrade]
@onready var active_level: Level = $"Level_1"
@onready var ball: Ball = $Ball
@onready var player: Player = %Player
@onready var ui: Control = $UI

var taken_upgrades : Array[String] = []

func _ready() -> void:
	SignalBus.connect("switch_scene", switch_scene)

func switch_scene(location : String):
	ui.hide()
	var loaded_scene : Level
	player.visible = false
	ball.visible = false
	match location:
		"next_level":
			level_idx += 1
			if !scenes.get(str(level_idx)): level_idx = 0
			loaded_scene = scenes.get(str(level_idx)).instantiate()
			player.position = Vector2(32, 157)
			ball.position = Vector2(128, 112)
		"Shop":
			loaded_scene = scenes.get('shop').instantiate()
			player.position = Vector2(32, 157)
			ball.position = Vector2(-10, -10)
		"Level_1":
			loaded_scene = scenes.get('1').instantiate()
			player.position = Vector2(32, 157)
			ball.position = Vector2(128, 112)
	
	get_tree().paused = true
	
	loaded_scene.position.x = 280
	add_child.call_deferred(loaded_scene)
	if loaded_scene.starting_image != null:
		SignalBus.emit_signal("reset_ink", loaded_scene.starting_image)
	else: SignalBus.emit_signal("reset_ink", null)
	transition_manager.node1 = active_level
	transition_manager.node2 = loaded_scene
	
	transition_manager.transition_scenes()
	await transition_manager.transition_finished
	
	active_level.queue_free()
	player.visible = true
	ball.visible = true
	active_level = loaded_scene
	ui.show()

func add_upgrade_to_array(upgrade : Upgrade):
	upgrade_array.append(upgrade)
