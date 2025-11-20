class_name TransitionManager extends Node

signal transition_finished

var node1 : Node2D
var node2 : Node2D


func transition_scenes():
	SignalBus.emit_signal("resetInking")
	var transition_tween : Tween = create_tween().set_parallel(true)
	transition_tween.tween_property(node1, "position", Vector2(-280, 0), 2.0).set_trans(Tween.TRANS_QUINT)
	transition_tween.tween_property(node2, "position", Vector2(0, 0), 2.0).set_trans(Tween.TRANS_QUINT)
	await transition_tween.finished
	transition_finished.emit()
	get_tree().paused = false
	SignalBus.emit_signal("enable_door")
