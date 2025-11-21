class_name UpgradeItem extends Node2D

@export var upgrade_resource_1 : Upgrade
@export var upgrade_resource_2 : Upgrade
@export var texture : Texture2D
@export var cost : int = 0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label


func _ready() -> void:
	setup()


func setup():
	sprite_2d.texture = texture
	label.text = str(cost)
	if upgrade_resource_1:
		upgrade_resource_1.do_upgrade()
	if upgrade_resource_2:
		upgrade_resource_2.do_upgrade()
