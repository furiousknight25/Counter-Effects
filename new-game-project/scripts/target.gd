class_name Target extends StaticBody2D

## Ideally, the game increments a living_targets variable by 1 each time this signal is emitted.
signal targetSpawned
## Ideally, the game reduces living_targets by 1 each time this signal is emitted, and checks if living_targets is 0 (or less) only when this signal is emitted.
signal targetBroken
# Implementing both signals like proposed above should be a smooth way to track when the player beats the level.

## Loses 1 health per hit; breaks at 0 health.
@export var health = 5
## Determines both the hitbox and the sprite.
@export_enum("circle", "kite", "corner") var shape: int = 0

var dead = false # set to true to avoid a target dying twice in the same frame.
# genuinely no clue if that will ever be a problem, but if we have 2 balls in play it's a good thing to have.

func _ready():
	
	emit_signal("targetSpawned")
	add_child(load("res://scenes/target_collision_shapes/" + str(shape) + ".tscn").instantiate())

#ALL things that CAN be hit should have this function, the velocity is inputed if we want to measure speed, but mainly for directional particles when we get there
func hit(velocity : Vector2):
	health -= 1
	if health <= 0 and !dead:
		dead = true
		emit_signal("targetBroken")
		queue_free()
