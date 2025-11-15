extends Node2D

@export var upgrade_resource : Upgrade
@export var texture : Texture2D
@export var cost : int = 0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label


func _ready() -> void:
	setup()


func setup():
	sprite_2d.texture = texture
	label.text = str(cost)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		upgrade_resource.do_upgrade()
