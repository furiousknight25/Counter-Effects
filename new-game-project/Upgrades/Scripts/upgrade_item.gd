class_name UpgradeItem extends Node2D

@export var upgrade_resource_1 : Upgrade
@export var upgrade_resource_2 : Upgrade
@export var texture : Texture2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var description: Label = $Description

var upgrade_name : String
var can_obtain : bool = false
var upgrades_dict : Dictionary[String, Array] = {
	"moon_boots" : ["res://Upgrades/Resources/AirSpeed.tres", "res://Upgrades/Resources/IncreaseGravity.tres"],
	"ball_trail" : ["res://Upgrades/Resources/BallTrail.tres"],
	"stronger_ball" : ["res://Upgrades/Resources/BiggerBall.tres" , "res://Upgrades/Resources/SlowerBall.tres"],
	"linear_speed_up" : ["res://Upgrades/Resources/SpeedOverTime.tres"]
}

func _ready() -> void:
	SignalBus.connect("remove_upgrades", queue_free)
	


func _process(_delta: float) -> void:
	if can_obtain == true and Input.is_action_just_pressed("Interact"):

		call_upgrades()
		SignalBus.emit_signal("upgrade_taken", upgrade_name)
		SignalBus.emit_signal("remove_upgrades")




func setup():
	sprite_2d.texture = texture
	label.visible = false
	description.visible = false
	
	if upgrade_resource_2:
		description.text = upgrade_resource_1.description + "\n\n" + upgrade_resource_2.description
	else:
		description.text = upgrade_resource_1.description
	

func call_upgrades():
	if upgrade_resource_1:
		upgrade_resource_1.do_upgrade()
	if upgrade_resource_2:
		upgrade_resource_2.do_upgrade()
	


func _on_area_2d_body_entered(_body: Node2D) -> void:
	label.visible = true
	description.visible = true
	can_obtain = true


func _on_area_2d_body_exited(_body: Node2D) -> void:
	label.visible = false
	description.visible = false
	can_obtain = false


func set_upgrade(key : String):

	upgrade_name = key
	upgrade_resource_1 = load(upgrades_dict[key][0])
	if upgrades_dict[key].size() > 1:
		upgrade_resource_2 = load(upgrades_dict[key][1])
	else:
		upgrade_resource_2 = null
	setup()
