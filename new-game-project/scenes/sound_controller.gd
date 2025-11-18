extends Node
class_name PlayerSoundController
@onready var foot_timer: Timer = $FootTimer


func set_walking_on():
	if foot_timer.is_stopped(): foot_timer.start()
	foot_timer.paused = false
	
func set_walking_off(): 
	foot_timer.paused = true
