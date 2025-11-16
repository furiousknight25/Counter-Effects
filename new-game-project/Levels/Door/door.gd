class_name Door extends Node2D

signal door_entered

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		door_entered.emit()
