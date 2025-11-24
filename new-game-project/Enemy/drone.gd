extends Node3D

var dir = 1.0
var delt = 0.0
func _process(delta: float) -> void:
	delt += delta
	position.y = sin(delt) * .1
	rotation.z = sin(delt * .4) * .3
	
	print(dir)
	if dir > 0: rotation.y= lerp_angle(rotation.y, deg_to_rad(50), delta * 5)
	else: rotation.y= lerp_angle(rotation.y, -deg_to_rad(50), delta * 5)
	
