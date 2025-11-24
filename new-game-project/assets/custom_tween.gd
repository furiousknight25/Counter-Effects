extends Node
class_name CurveTween

signal curve_tween(sat)
signal tween_done

@export var curve : Curve
var start := 0.0
var end := 1.0

func play(duration = 1.0, start_in = 0.0, end_in = 1.0):
	assert(curve, 'needa curve my brother bro bro')
	start = start_in
	end = end_in
	var tween = get_tree().create_tween()
	tween.tween_method(interp.bind(), start, end, duration)
	await tween.finished
	emit_signal("tween_done")
	
func interp(sat): #when the play method is called a value is interpolated based on your curve
	emit_signal('curve_tween', start + ((end-start) * curve.sample(sat)))
	
	
