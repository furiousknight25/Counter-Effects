class_name Door extends Node2D

signal door_entered

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		collision_shape_2d.set_deferred("disabled", true)
		door_entered.emit()
