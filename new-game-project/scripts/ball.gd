extends CharacterBody2D
class_name Ball
## HOW TO USE
# you only really need to acess the bottom two functions, hit_ball to move the ball and hit_object
@onready var spring_x: Spring = $SpringX
@onready var spring_y: Spring = $SpringY
@onready var visual_follow_line: VisualFollowLine = $VisualFollowLine

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
	velocity.x += spring_x.interpolate_spring(position.x, delta) * delta#bungie cord
	velocity.y += spring_y.interpolate_spring(position.y, delta) * delta
	
	if is_on_wall(): #bouncing off wall
		var wall_noraml = get_wall_normal()
		if wall_noraml != null: 
			velocity = velocity.bounce(wall_noraml)
			#Vector2(randf_range(-.1,.1), randf_range(-.1,.1)) we can use equation to modify and add random
	
	move_and_slide()
	visual_follow_line.spawn_line(global_position)
	
	var last_hit = get_last_slide_collision()
	if last_hit != null:
		hit_object(last_hit.get_collider())


func hit_ball(direction : Vector2, strength : float, freeze_length : float = 0): #direction is your target position, it WILL be normalized and you get a lashing if you dont like it
	if freeze_length > 0.0:
		set_state_freezing(freeze_length)
	
	speed += strength
	velocity = direction * speed
	
func hit_object(object):
	if object.is_in_group("Hitable"):
		object.hit(velocity)
	
