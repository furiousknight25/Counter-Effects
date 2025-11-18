extends CharacterBody2D
class_name Ball
## HOW TO USE
# you only really need to acess the bottom two functions, hit_ball to move the ball and hit_object
@onready var spring_x: Spring = $SpringX
@onready var spring_y: Spring = $SpringY
@onready var visual_follow_line: VisualFollowLine = $VisualFollowLine
@export var spring_enabled = false
var speed : float = 1.0

enum STATES {FREEZE, MOVING}
var cur_state = STATES.MOVING

func _ready() -> void:
	spring_x.goal = global_position.x
	spring_y.goal = global_position.y

func _process(delta: float) -> void:
	match cur_state:
		STATES.FREEZE: #when the ball gets hit, might activate this state. FREEZE frame logic, also prevents player from getting hit
			freeze_process(delta)
		STATES.MOVING:
			moving_process(delta)

func set_state_freezing(freeze_time):
	cur_state = STATES.FREEZE
	await get_tree().create_timer(freeze_time).timeout
	set_state_moving()

func set_state_moving():
	cur_state = STATES.MOVING

func freeze_process(delta):
	pass #use this for visual logic

func moving_process(delta):
	if spring_enabled:
		velocity.x += spring_x.interpolate_spring(position.x, delta) * delta#bungie cord
		velocity.y += spring_y.interpolate_spring(position.y, delta) * delta
	
	var motion = velocity * delta
	var collision = move_and_collide(motion)
	if collision: #bouncing off wall
		var wall = collision.get_collider()
		if wall != null: 
			var normal = collision.get_normal()
			velocity = velocity.bounce(normal)
			$Sounds/BallBounce.play()
			#Vector2(randf_range(-.1,.1), randf_range(-.1,.1)) we can use equation to modify and add random
		
		
	visual_follow_line.spawn_line(global_position)
	
	if collision != null:
		hit_object(collision.get_collider())

func hit_ball(direction : Vector2, strength : float, freeze_length : float = 0): #direction is your target position, it WILL be normalized and you get a lashing if you dont like it
	if freeze_length > 0.0:
		set_state_freezing(freeze_length)
	direction = direction.normalized()
	Camera.add_trauma(strength * .0001, direction)
	speed += strength
	velocity = direction * speed
	apply_slow_motion(.1, .1)
	$Sounds/BallHit.play()
	
func hit_object(object):
	if object.is_in_group("Hitable"):
		object.hit(velocity)
		

# Call this function to trigger the slow-mo
# Example: apply_slow_motion(0.1, 0.2)
# This means 10% speed for 0.2 real-time seconds.
func apply_slow_motion(slow_factor: float, duration: float):
	# 1. Store the normal time scale so we can restore it
	var original_time_scale = Engine.time_scale

	# 2. Slow the game down
	Engine.time_scale = slow_factor

	# 3. Create a timer that ignores the time scale
	# The arguments are: (duration, process_always, process_pause, ignore_time_scale)
	# We set 'ignore_time_scale' to 'true'.
	await get_tree().create_timer(duration, false, false, true).timeout

	# 4. Restore the time scale
	Engine.time_scale = original_time_scale
