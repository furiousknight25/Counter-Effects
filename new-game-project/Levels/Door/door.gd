class_name Door extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	SignalBus.connect("enable_door", enable_door)
	animation_player.play("Arrow_Tween")


func enable_door():
	await get_tree().create_timer(0.1).timeout
	collision_shape_2d.set_deferred("disabled", false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		collision_shape_2d.set_deferred("disabled", true)
		SignalBus.emit_signal("switch_scene", "next_level")
