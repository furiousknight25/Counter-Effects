extends Node3D

var dir = 1.0
var delt = 0.0
var z_range = .4

func _process(delta: float) -> void:
	z_range = move_toward(z_range, 1.0, delta)
	delt += delta
	position.y = sin(delt) * .1
	rotation.z = sin(delt * .4) * .3
	
	if dir > 0: rotation.y= lerp_angle(rotation.y, deg_to_rad(50), delta * 5)
	else: rotation.y= lerp_angle(rotation.y, -deg_to_rad(50), delta * 5)
	
