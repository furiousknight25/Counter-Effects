extends Node
@onready var ball: Ball = $".."


func _process(delta: float) -> void:
	if !Director.debug_mode: return
	
	if Input.is_action_just_pressed("click"):
		ball.hit_ball((ball.get_global_mouse_position() - ball.global_position), 5.0)
