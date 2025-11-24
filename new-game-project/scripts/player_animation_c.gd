extends AnimationTree
class_name PlayerAnim

@onready var player: Player = $".."
@onready var sprite_2d: AnimatedSprite2D = $"../Sprite2D"
@onready var sound_controller: PlayerSoundController = $"../SoundController"
@export var base_speed_threshold := 10.0

# Memory for landing sound
var was_on_floor := true

func _ready() -> void:
	active = true # Force the tree to be active

func _process(_delta: float) -> void:
	# 1. GET PLAYBACK & INFO
	var playback = get("parameters/playback")
	if not playback: return
	
	var current_node = playback.get_current_node()
	var is_on_floor = player.is_on_floor()
	var is_moving = abs(player.velocity.x) > base_speed_threshold
	
	# Check if we are currently in an attack animation
	var is_attacking = current_node == "Hit" or current_node == "Hit_Air"

	# --- 2. HANDLE DIRECTION (Visuals only) ---
	# CHANGE: Only let velocity dictate facing direction if we are NOT attacking.
	# If we ARE attacking, the anim_hit function already set the correct direction,
	# and we want to lock it there until the animation finishes.
	if not is_attacking:
		if is_on_floor and abs(player.velocity.x) > 10:
			sprite_2d.flip_h = player.velocity.x < 0

	# --- 3. HANDLE SOUNDS ---
	# (Sounds can play regardless of attack state)
	if is_on_floor and not was_on_floor:
		$"../SoundController/Landonground".play()
		playback.start("land")
		was_on_floor = is_on_floor
		
		return
	
	was_on_floor = is_on_floor
	if is_on_floor and is_moving: 
		sound_controller.set_walking_on()
	else:  
		sound_controller.set_walking_off()

	# --- 4. THE "ACTION LOCK" ---
	# If attacking, stop here. Don't let movement logic interrupt the attack animation.
	if is_attacking:
		return
	
	# --- 5. STATE ENFORCER (Movement Logic) ---
	if is_on_floor and current_node != "land":
		if is_moving:
			playback.travel("walk")
		else:
			playback.travel("idle")
	elif current_node != "jump" and current_node != "land":
		playback.travel("top")
		
	

func idle():
	var playback = get("parameters/playback")
	playback.travel('idle')
# --- ACTION FUNCTIONS ---

func jump_anim():
	var playback = get("parameters/playback")
	was_on_floor = false
	$"../SoundController/Jump".play()
	playback.start("jump") 

func anim_hit(direction: Vector2):
	var playback = get("parameters/playback")
	
	# This sets the direction *once* at the start of the attack.
	# The new logic in _process ensures this doesn't get overwritten.
	sprite_2d.flip_h = direction.x > 0
	
	if player.is_on_floor():
		playback.start("Hit")
		set('parameters/Hit/blend_position', -direction.normalized().y)
	else:
		playback.start("Hit_Air")
		set('parameters/Hit_Air/blend_position', -direction.normalized().y)
