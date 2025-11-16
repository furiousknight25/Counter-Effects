extends Node2D

@onready var door: Door = %Door


func _ready() -> void:
	if door:
		door.connect("door_entered", call_to_switch_scene)


func call_to_switch_scene():
	SignalBus.emit_signal("switch_scene", self, load("res://Levels/Level Scenes/Level_1.tscn"))
