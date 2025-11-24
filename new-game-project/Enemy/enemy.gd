extends CharacterBody2D
@onready var inking : Inking = get_tree().get_nodes_in_group("Inking")[0]
@onready var player : Player = get_tree().get_nodes_in_group("Player")[0]
@onready var drone: Node3D = $drone

var invince_time = .1
var invince = false

func _process(delta: float) -> void:
	
	velocity = position.direction_to(player.position) * 25
	if player.position.x > position.x: 
		drone.dir = 1
	else:drone.dir = -1
	move_and_slide()
	

func hit(direction : Vector2):
	
	if !invince:
		invince = true
		inking.splat_player(position, direction.normalized())
		modulate = Color("ff0000")
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, .5)
	
		velocity += direction
		
		await get_tree().create_timer(invince_time).timeout
		invince = false
