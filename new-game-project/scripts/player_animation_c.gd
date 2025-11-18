extends AnimationTree
class_name PlayerAnim
@onready var player: Player = $".."
@export var base_speed_threshold := 10.0
@onready var sprite_2d: AnimatedSprite2D = $"../Sprite2D"
@onready var sound_controller: PlayerSoundController = $"../SoundController"

# This is the "memory" we need.
# We'll use it to detect the *exact frame* we land.
var was_on_floor := true


func _process(delta: float) -> void:
	#sprite_2d.play()
	# --- 1. GET PLAYER'S CURRENT STATE ---
	var playback = get("parameters/playback")
	if playback:
		if playback.get_current_node() != "Hit":
			sprite_2d.flip_h = !bool(clampi(sign(player.velocity.x) + 1, 0, 1))
		#print("Current State: ", playback.get_current_node())
	
	var is_on_floor: bool = player.is_on_floor()
	var is_moving: bool = abs(player.velocity.x) > base_speed_threshold
	# --- 2. RESET ALL "ONE-SHOT" TRIGGERS ---
	# We set these to false *every frame* by default.
	# This way, they only fire once when we set them to true.
	set("parameters/conditions/jump", false)
	set("parameters/conditions/land", false)
	set("parameters/conditions/land_moving", false)
	set("parameters/conditions/hitting", false)
	set('parameters/conditions/top', false)
	# --- 3. SET "CONTINUOUS STATE" PARAMETERS ---
	# These parameters are set every frame to whatever the player is *currently* doing.
	# Your state machine (in "Auto" mode) will react to these changes.
	
	# Set air/ground state
	set("parameters/conditions/in_air", not is_on_floor)
	
	# Set floor movement states
	if is_on_floor and is_moving: sound_controller.set_walking_on()
	else:  sound_controller.set_walking_off()
	set("parameters/conditions/idle", is_on_floor and not is_moving)
	set("parameters/conditions/walk", is_on_floor and is_moving)
	
	# --- 4. CHECK FOR "ONE-SHOT" TRIGGERS ---
	# CHECK FOR LANDING: Only on the *single frame* we go from
	# "in air" (was_on_floor == false) to "on floor" (is_on_floor == true).
	if !is_on_floor and player.velocity.y > 0:
		set('parameters/conditions/top', true)
	
	if is_on_floor and not was_on_floor:
		if is_moving:
			set("parameters/conditions/land_moving", true)
		else:
			set("parameters/conditions/land", true)
	
	# --- 5. STORE STATE FOR NEXT FRAME ---
	# This "remembers" our floor status so we can detect landing next frame.
	was_on_floor = is_on_floor

func jump_anim():
	was_on_floor = true
	set("parameters/conditions/jump", true)
	$"../SoundController/Jump".play()
	
func anim_hit(direction: Vector2):
	sprite_2d.flip_h = bool(clampi(sign(direction.x) + 1, 0, 1))
	var playback = get("parameters/playback")
	playback.travel("Hit")
	set('parameters/Hit/blend_position', -direction.normalized().y)
