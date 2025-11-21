extends Panel

@onready var white_l: Label = $White
@onready var black_l: Label = $Black

var black := 0
var white := 0

func _ready() -> void:
	SignalBus.connect("reset", reset)


func _process(_delta: float) -> void:
	white_l.text = str(white)
	black_l.text = str(black)
	#position.y = lerp(position.y, -30.0, delta * 4)
	#TODO make observer code for the changes here :D

func set_bw(b,w):
	black = b
	white = w
	position.y = 25


func reset():
	position.y = -31
