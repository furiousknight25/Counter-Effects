extends CharacterBody2D

@onready var spring_x: Spring = $SpringX
@onready var spring_y: Spring = $SpringY
var speed : float = 10.0

@onready var line_2d: Line2D = $Line2D


func _physics_process(delta: float) -> void:
	
	
	if Input.is_action_just_pressed("click"):
		var dir = (get_global_mouse_position() - global_position).normalized()
		velocity = dir * speed
		speed += 500
	
	print(speed)
		
	if is_on_wall():
		var wall_noraml = get_wall_normal()
		if wall_noraml != null: 
			velocity = velocity.bounce(wall_noraml)
			velocity += Vector2(randf_range(-.1,.1), randf_range(-.1,.1))
			#position -= wall_noraml * .1
		
	
	velocity.x += spring_x.interpolate_spring(position.x, delta)
	velocity.y += spring_y.interpolate_spring(position.y, delta)
	
	move_and_slide()
	
	await get_tree().create_timer(.5).timeout
	line_2d.add_point(line_2d.to_local(global_position))
	await get_tree().create_timer(4).timeout
	line_2d.remove_point(0)
