extends CharacterBody3D

@onready var player: CharacterBody3D = $"../Player"
@onready var navigation_agent_3d: NavigationAgent3D = $CSGCylinder3D/NavigationAgent3D

func _process(delta: float) -> void:
	
	navigation_agent_3d.target_position = player.global_position
	var next_path_position = navigation_agent_3d.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	
	velocity = direction
	
	velocity.y -= 9.8
	move_and_slide()
