extends Node2D

@onready var strike_label: Label = $StrikeLabel


var strike: int = 0 #track strikes

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		add_strike(1)

#Strike (score) system
func add_strike(amount: int):
	strike += amount
	update_strike_label()

func update_strike_label():
	if strike_label:
		strike_label.text = "Strikes: %d" % strike
