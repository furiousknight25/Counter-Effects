class_name GameStateManager extends Node

var level_idx : int = 0
@export var scenes : Dictionary[String, PackedScene]

@export var rouge_like_levels : Array[PackedScene]
@onready var transition_manager: TransitionManager = $TransitionManager
@onready var upgrade_array : Array[Upgrade]
@export var active_level: Level 
@onready var ball: Ball = $Ball
@onready var player: Player = %Player
@onready var ui: Control = $UI
@onready var inking: Inking = $UI/Inking
@onready var animation_player: AnimationPlayer = $UI/Inking/SubViewportInk/AnimationPlayer

signal done_anim 

var taken_upgrades : Array[String] = []

func _ready() -> void:
	SignalBus.connect("switch_scene", switch_scene)

func switch_scene(location : String):
	disable_scene()
	await done_anim
	var loaded_scene : Level
	
	match location:
		"next_level":
			level_idx += 1
			if level_idx <= 3: 
				loaded_scene = rouge_like_levels[randi_range(0, rouge_like_levels.size() - 1)].instantiate()
				Music.transition_to_open_your_mind()
			else:
				loaded_scene = scenes.get('final').instantiate()
		"shop":
			loaded_scene = scenes.get('shop').instantiate()
		"Level_1":
			loaded_scene = scenes.get('1').instantiate()
	
	if loaded_scene.player != null:
		player.pos_tween(loaded_scene.player.position)
	else:
		player.pos_tween(Vector2(32, 157))
	#get_tree().paused = true
	
	loaded_scene.position.x = 280
	add_child.call_deferred(loaded_scene)
	transition_manager.node1 = active_level
	transition_manager.node2 = loaded_scene
	
	transition_manager.transition_scenes()
	await transition_manager.transition_finished
	if loaded_scene.starting_image != null:
		SignalBus.emit_signal("reset_ink", loaded_scene.starting_image)
	else: SignalBus.emit_signal("reset_ink", null)
	
	active_level.queue_free()
	active_level = loaded_scene
	start_scene()
	
	if loaded_scene.ball != null:
		ball.position = loaded_scene.ball.position
	else:
		ball.position = Vector2(-10, -10)
	
	if location == "Shop": inking.shop()

func disable_scene():
	animation_player.play('close')
	player.set_freeze(true)
	ball.set_state_freezing()

func start_scene():
	animation_player.play('open')
	ball.set_state_moving()

func add_upgrade_to_array(upgrade : Upgrade):
	upgrade_array.append(upgrade)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "close":
		emit_signal("done_anim")
