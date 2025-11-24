extends CharacterBody2D
@onready var inking : Inking = get_tree().get_nodes_in_group("Inking")[0]
@onready var player : Player = get_tree().get_nodes_in_group("Player")[0]
@onready var drone: Node3D = $drone
@onready var cpu_particles_3d: CPUParticles3D = $drone/CPUParticles3D
var invince_time = .1
var invince = false
var dead = false
var health = 5

var speed = 1
func _process(delta: float) -> void:
	if dead:
		velocity.y += 9.8
		move_and_slide()
		return
	velocity += position.direction_to(player.position + Vector2(0, -50)) * delta * 5 * speed
	if player.position.x > position.x: 
		drone.dir = 1
	else:drone.dir = -1
	move_and_slide()

func hit(direction : Vector2):
	if !invince:
		health -= 1
		$hurtpart.restart()
		if health <= 0:
			die()
			return
		if health < 5:
			cpu_particles_3d.emitting = true
		if health == 1:
			speed = 2
			$Mad.play()
		cpu_particles_3d.amount = (5 - health) * 2
		$drone.z_range += 1
		$hit.play()
		invince = true
		inking.splat_player(position, direction.normalized())
		modulate = Color("ff0000")
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, .5)
		
		velocity -= direction
		
		await get_tree().create_timer(invince_time).timeout
		invince = false


func die():
	$death.play()
	$CollisionShape2D.set_deferred("disabled", true)
	velocity.y += 10
	dead = true
	await get_tree().create_timer(2.0).timeout
	Camera.add_trauma(1.0, -global_position.direction_to(player.global_position))


func _on_timer_timeout() -> void:
	if dead:return
	inking.spawned_spot(Vector2(velocity.x * .01,9.8), global_position, inking.create_circle_image(randf_range(1,3)), .9, Color.BLACK)
