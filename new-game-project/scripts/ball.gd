extends CharacterBody2D
class_name Ball
## HOW TO USE
# you only really need to acess the bottom two functions, hit_ball to move the ball and hit_object
@onready var spring_x: Spring = $SpringX
@onready var spring_y: Spring = $SpringY
@onready var visual_follow_line: VisualFollowLine = $VisualFollowLine
@onready var inking : Inking = get_tree().get_nodes_in_group("Inking")[0]
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var spring_enabled = false
var base_speed : float = 1.0
var speed : float = 1.0
var strength : float = 30.0

enum STATES {FREEZE, MOVING}
var cur_state = STATES.MOVING

enum InkPattern {DEFAULT, LINE, CIRCLE}
var ink_pattern : int = InkPattern.DEFAULT

var linear_speed_increase : bool = false
var round_has_started : bool = false

func _ready() -> void:
	spring_x.goal = global_position.x
	spring_y.goal = global_position.y
	
	SignalBus.connect("reset", reset)
	SignalBus.connect("upgrade_ball", upgrade_ball)


func _process(delta: float) -> void:
	match cur_state:
		STATES.FREEZE: #when the ball gets hit, might activate this state. FREEZE frame logic, also prevents player from getting hit
			freeze_process(delta)
		STATES.MOVING:
			moving_process(delta)
	
	if linear_speed_increase == true and round_has_started == true:
		increase_speed_over_time(delta)

func set_state_freezing(freeze_time: float = 0) -> void:
	cur_state = STATES.FREEZE
	collision_shape_2d.set_deferred("disabled", true)
	if freeze_time > 0:
		var original_time_scale = 1.0
		Engine.time_scale = .1
		await get_tree().create_timer(freeze_time, false, false, true).timeout
		Engine.time_scale = original_time_scale
		set_state_moving()

func set_state_moving():
	collision_shape_2d.set_deferred("disabled", false)
	cur_state = STATES.MOVING

func freeze_process(_delta):
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

func hit_ball(direction : Vector2, freeze_length : float = 0): #direction is your target position, it WILL be normalized and you get a lashing if you dont like it
	if freeze_length > 0.0:
		set_state_freezing(freeze_length)
	inking.splat_ball(global_position, direction.normalized())
	
	direction = direction.normalized()
	Camera.add_trauma(strength * .0001, direction)
	if linear_speed_increase == false:
		speed += strength
	velocity = direction * speed

	$Sounds/Ink1.play()
	$Sounds/BallHit.play()
	SignalBus.emit_signal("ball_hit")
	
	if round_has_started == false:
		round_has_started = true
	
func hit_object(object):
	if object.is_in_group("Hitable"):
		object.hit(velocity)
		
		self.set_collision_mask_value(4, false)
		set_collision_layer_value(2, false)
		await get_tree().create_timer(.2).timeout
		self.set_collision_mask_value(4, true)
		set_collision_layer_value(2, true)

func drop_the_ball(amt, vel):
	await get_tree().physics_frame
	if amt < 100:
		amt += 1
		print(amt)
		vel += .2
		position.y += vel
		drop_the_ball(amt, vel)

func _on_end_game_timer_timeout() -> void:
	set_state_freezing()


func reset() -> void:
	speed = base_speed


func upgrade_ball(upgrade : BallUpgrade):
	upgrade.upgrade_ball(self)


func increase_speed_over_time(delta : float):
	speed = speed + (delta * 48)
	velocity = velocity.normalized() * speed
	
