class_name Target extends StaticBody2D

## Ideally, the game increments a living_targets variable by 1 each time this signal is emitted.
signal targetSpawned
## Ideally, the game reduces living_targets by 1 each time this signal is emitted, and checks if living_targets is 0 (or less) only when this signal is emitted.
signal targetBroken
# Implementing both signals like proposed above should be a smooth way to track when the player beats the level.
@onready var inking : Inking = get_tree().get_nodes_in_group("Inking")[0]
## Loses 1 health per hit; breaks at 0 health.
@export var health = 5
## Determines both the hitbox and the sprite.
@export_enum("circle", "kite",  "square") var shape: int = 0
var speed = 1.0
var dead = false # set to true to avoid a target dying twice in the same frame.
# genuinely no clue if that will ever be a problem, but if we have 2 balls in play it's a good thing to have.
var col 
func _ready():
	
	emit_signal("targetSpawned")
	col = load("res://scenes/target_collision_shapes/" + str(shape) + ".tscn").instantiate()
	add_child(col)
	beep()

var off
func beep():
	
	await get_tree().create_timer(health * .1).timeout
	$Beep.play()
	
	off = !off
	if off:
		col.get_children()[0].play('off')
	else:
		$Beep.play()
		col.get_children()[0].play('on')
	beep()
	

#ALL things that CAN be hit should have this function, the velocity is inputed if we want to measure speed, but mainly for directional particles when we get there
func hit(velocity : Vector2):
	$hit.play()
	health -= 1
	if health == 1:
		$mad.play()
	inking.stamp_image(global_position, Color.BLACK, inking.create_circle_image(20 - (health * 3)))
	
	if health <= 0 and !dead:
		for i in 40:
			inking.spawned_spot(Vector2(randf_range(-45.0,45.0),randf_range(-15.0,15.0)), global_position, inking.create_circle_image(randf_range(3,6)), randf_range(.2,.4), Color.BLACK)
		dead = true
		emit_signal("targetBroken")
		hide()
		await get_tree().create_timer(.5).timeout
		queue_free()

func splash():
	pass
