extends CharacterBody2D
class_name Player
@export_group("possible variables that could be affected by 'effects'")
@export var jump_strength : int
@export var speed : int
@export var gravity = 980
@export var slowdown_speed = 12.0
@export var hit_time_frame : float = .2
@export var cooldown_time : float = .3
@export var invince_time = .1
var cooldown_on : bool= false
var can_hit : bool = false

@onready var sprite = $Sprite2D
@onready var weapon: Area2D = $Weapon
@onready var animation_tree: PlayerAnim = $AnimationTree
@onready var inking : Inking = get_tree().get_nodes_in_group("Inking")[0]

var walk_animation_speed = 0
var dash_strength = 10
var buff_jump = 0.0
var jump_length = .1
var coyote_time = .1
var dash_timer = 0
var sin : float = 0.0
var falling_stretch = 1.0
var squishable = false
const BASESCALE = 1.00

var health : int = 500


func _ready() -> void:
	SignalBus.connect("upgrade_player", upgrade_player)


func _process(delta):
	weapon_c(delta)
	
	movement(delta)
	#visuals(delta)

func weapon_c(delta):
	weapon.rotation = lerp_angle(weapon.rotation,global_position.angle_to_point(get_global_mouse_position()), delta * 12)
	
	if Input.is_action_just_pressed("click") and !cooldown_on: swing()
	
	var bodies = weapon.get_overlapping_bodies()
	for i in bodies:
		if i is Ball and can_hit:
			can_hit = false
			i.hit_ball(get_global_mouse_position() - global_position, 50, .1)
	
	if can_hit: weapon.modulate = Color.GRAY
	else: weapon.modulate = Color.WHITE
	
func swing():
	can_hit = true
	cooldown_on = true
	velocity += (global_position - get_global_mouse_position()).normalized() * 120
	animation_tree.anim_hit(global_position - get_global_mouse_position())
	await get_tree().create_timer(cooldown_time).timeout
	cooldown_on = false
	can_hit = false
	

func movement(delta):
	var direction = Input.get_axis('left', "right")
	
	if direction:
		velocity.x = lerp(velocity.x, speed * direction, 12 * delta) #add jump buffer later
		#dash function
	dash_timer -= delta
	
	if is_on_floor() and velocity.length() > 2:
		velocity.x = lerp(velocity.x, 0.0, slowdown_speed*delta)
	
	if Input.is_action_just_pressed("up"):
		buff_jump = .2
	if is_on_floor():
		coyote_time = .1
	if coyote_time > 0 and buff_jump > 0: #jump here
		animation_tree.jump_anim()
		jump_length = .2
		coyote_time = 0
		buff_jump = 0
		velocity.y -= jump_strength
	
	if Input.is_action_just_released('up'):
		jump_length = 0
	if jump_length > 0 and Input.is_action_pressed('up'):
		velocity.y -= 1400 * delta
		jump_length -= delta
	
	velocity.y += 980 * delta
	move_and_slide()
func visuals(delta):
	
#region walking
	if is_on_floor():
		if velocity.length() > 20:
			sin = (sin + (delta * 15))
			if sin > PI: 
				sin = 0.0
				sprite.scale += Vector2(-.1, .1) * BASESCALE
			
			walk_animation_speed += velocity.x * .0005
			sprite.scale = sprite.scale.lerp(Vector2(1.2, .8) * BASESCALE, delta * 5)
			#sprite.position = Vector2(0,9.0) - Vector2(0, abs(sin(sin) * 5))
		else:
			sin = lerp(sin, 0.0, delta * 12.0)
			#sprite.position = Vector2(0,9.0) - Vector2(0, abs(sin(sin) * 5))
#endregion
	
#region jumping
	if coyote_time > 0 and buff_jump > 0: #jump here
			sprite.scale = Vector2(1.5 * BASESCALE, .6 * BASESCALE) 
			falling_stretch = 1.0
			if abs(velocity.x) > 20:
				var tween = get_tree().create_tween()
				tween.tween_property(sprite, "rotation", -wrapf(velocity.normalized().angle(), -PI/4, PI/4), .1)
				#sprite.rotation = -wrapf(velocity.normalized().angle(), -PI/4, PI/4)
#endregion

	sprite.scale.x = lerp(sprite.scale.x, 1.0 * BASESCALE, 12 * delta) #messing around with squshing you can delete
	sprite.scale.y = lerp(sprite.scale.y, 1.0 * BASESCALE, 12 * delta)
	
	if is_on_floor():
		var mult_x = 0
		if velocity.length() > 30:
			mult_x = velocity.normalized().x * .4
			sprite.scale = sprite.scale.lerp(Vector2(1.2, .8) * BASESCALE, delta * 5)
		
		sprite.rotation = lerp_angle(sprite.rotation, mult_x,delta * 8)
		falling_stretch = 1.0
		if squishable:
			squishable = false
			sprite.scale = Vector2(2, .3) * BASESCALE
			var tween = get_tree().create_tween()
			tween.tween_property(sprite, "scale", Vector2.ONE * BASESCALE, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		falling_stretch += delta
		if abs(velocity.x) > 20 and !abs(velocity.y) > 400:
			sprite.rotation = lerp_angle(sprite.rotation, wrapf(velocity.normalized().angle(), -PI/2, PI/2) + (-.2 * velocity.x * delta), 2 * delta)
		elif abs(velocity.y) > 400: #going rly fast
			var mult_xe = -Input.get_axis("left", "right") * .2
			sprite.scale = sprite.scale.lerp(Vector2(1.2, .8) * BASESCALE, delta * 5)
		
			sprite.rotation = lerp_angle(sprite.rotation, mult_xe, delta * 8)
			squishable = true
			print(mult_xe)
			falling_stretch += delta * 2
		
		sprite.scale = sprite.scale.lerp(Vector2(1/falling_stretch, falling_stretch) * BASESCALE, delta * 5) 

var invince = false
func hit(direction : Vector2):
	
	if !invince:
		invince = true
		set_health(get_health() - 1)
		inking.splat_player(position, direction.normalized())
		modulate = Color("ff0000")
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, .5)
		
		#sprite.scale.x += .2 * BASESCALE
		#sprite.scale.y -= .1 * BASESCALE
		velocity += direction
		
		var push_direction = -1
		if is_on_floor():
			push_direction = -1
		else:
			push_direction = -1
		await get_tree().create_timer(invince_time).timeout
		invince = false


func die():
	return
	queue_free()


func get_health() -> int:
	return health


func set_health(amount : int) -> void:
	health = amount
	
	if health <= 0:
		die()


func upgrade_player(upgrade : PlayerUpgrade):
	upgrade.upgrade_player(self)
