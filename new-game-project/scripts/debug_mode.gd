extends Node
@onready var ball: Ball = $".."
@export var debug_mode = false

func _process(_delta: float) -> void:
	if !debug_mode: return
	
	if Input.is_action_just_pressed("click"):
		ball.hit_ball((ball.get_global_mouse_position() - ball.global_position), 50.0)
