extends CharacterBody2D

@export var jump_strength : int
@export var speed : int
var gravity = 980
@onready var sprite = $Sprite2D

var walk_animation_speed = 0
var dash_strength = 10
var mouse_position
var buff_jump = 0.0
var jump_length = .1
var coyote_time = .1
var dash_timer = 0
var sin : float = 0.0
var falling_stretch = 1.0
var squishable = false

func _process(delta):
	mouse_position = get_global_mouse_position()
	var direction = Input.get_axis('left', "right")
	
	if direction:
		velocity.x = lerp(velocity.x, speed * direction, 12 * delta) #add jump buffer later
		#dash function
	dash_timer -= delta
	
	if is_on_floor():
		if velocity.length() > 20:
			sin = (sin + (delta * 15))
			if sin > PI: 
				sin = 0.0
				sprite.scale += Vector2(-.1, .1)
			velocity.x = lerp(velocity.x, 0.0, 12*delta)
			walk_animation_speed += velocity.x * .0005
			sprite.scale = sprite.scale.lerp(Vector2(1.2, .8), delta * 5)
			sprite.position = Vector2(-4,26.0) - Vector2(0, abs(sin(sin) * 5))
		else:
			sin = lerp(sin, 0.0, delta * 12.0)
			sprite.position = Vector2(-4,23.0) - Vector2(0, abs(sin(sin) * 5))
	
	if Input.is_action_just_pressed("up"):
				buff_jump = .2
	if is_on_floor():
		coyote_time = .1
	if coyote_time > 0 and buff_jump > 0: #jump here
		jump_length = .2
		coyote_time = 0
		buff_jump = 0
		velocity.y -= jump_strength
		sprite.scale = Vector2(1.5, .6)
		falling_stretch = 1.0
		if abs(velocity.x) > 20:
			var tween = get_tree().create_tween()
			tween.tween_property(sprite, "rotation", -wrapf(velocity.normalized().angle(), -PI/4, PI/4), .1)
			#sprite.rotation = -wrapf(velocity.normalized().angle(), -PI/4, PI/4)
	
	
	
	if Input.is_action_just_released('up'):
		jump_length = 0
	if jump_length > 0 and Input.is_action_pressed('up'):
		velocity.y -= 1400 * delta
		jump_length -= delta
	
	velocity.y += 980 * delta
	sprite.scale.x = lerp(sprite.scale.x, 1.0, 12 * delta) #messing around with squshing you can delete
	sprite.scale.y = lerp(sprite.scale.y, 1.0, 12 * delta)
	if is_on_floor():
		var mult_x = 0
		if velocity.length() > 30:
			mult_x = velocity.normalized().x * .4
			sprite.scale = sprite.scale.lerp(Vector2(1.2, .8), delta * 5)
		
		sprite.rotation = lerp_angle(sprite.rotation, mult_x,delta * 8)
		falling_stretch = 1.0
		if squishable:
			squishable = false
			sprite.scale = Vector2(2, .3)
			var tween = get_tree().create_tween()
			tween.tween_property(sprite, "scale", Vector2.ONE, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		falling_stretch += delta
		if abs(velocity.x) > 20 and !abs(velocity.y) > 400:
			sprite.rotation = lerp_angle(sprite.rotation, wrapf(velocity.normalized().angle(), -PI/2, PI/2) + (-.2 * velocity.x * delta), 2 * delta)
			print('toper')
		elif abs(velocity.y) > 400: #going rly fast
			var mult_xe = -Input.get_axis("left", "right") * .2
			sprite.scale = sprite.scale.lerp(Vector2(1.2, .8), delta * 5)
		
			sprite.rotation = lerp_angle(sprite.rotation, mult_xe, delta * 8)
			squishable = true
			print(mult_xe)
			falling_stretch += delta * 2
		
		sprite.scale = sprite.scale.lerp(Vector2(1/falling_stretch, falling_stretch), delta * 5)
	
	
	
	move_and_slide()

func hurt(direction, damage_percent):
	$Hurt.play()
	if damage_percent > 0: modulate = Color("ff0000")
	sprite.scale.x += .2
	sprite.scale.y -= .1
	velocity += direction
	
	var push_direction = -1
	if is_on_floor():
		push_direction = -1
	else:
		push_direction = -1
	sprite.rotate(sign((get_global_mouse_position().x-global_position.x)) * .8 * push_direction)
