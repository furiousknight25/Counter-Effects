extends Node2D
@onready var kids: Node2D = $"."

func _ready() -> void:
	SignalBus.connect("final", hello)
	
func hello():
	for i in kids.get_children():
		i.start()
