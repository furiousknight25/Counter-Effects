extends Node2D

@onready var yang_part: CPUParticles2D = $Yang/YangPart
@onready var yin_part: CPUParticles2D = $Yin/YinPart

func _on_timer_timeout() -> void:
	yang_part.emitting = false
	yin_part.emitting = false

func trans_in():
	rotation = 0
	get_tree().create_tween().tween_property(self, "position", Vector2(127,80), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func trans_out(winner: bool):
	position.y += 12
	get_tree().create_tween().tween_property(self, "position", Vector2(127,-80), 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if winner:
		spin(.5,0)
		print('yin wins')
	else:
		spin(-.5,0)
		print('yang wins')

func spin(dir, amt):
	await get_tree().process_frame
	if amt < 10000:
		rotation += dir
		amt += 1
		spin(dir, amt)
		
func mark(who : bool):
	if who: #yang
		yang_part.emitting = true
		rotation -= .01
	else: #yin
		yin_part.emitting = true
		rotation += .01
