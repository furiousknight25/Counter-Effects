extends Node2D

@onready var yang_part: CPUParticles2D = $Yang/YangPart
@onready var yin_part: CPUParticles2D = $Yin/YinPart
@onready var yang: Sprite2D = $Yang
@onready var yin: Sprite2D = $Yin


var dead = false
func _on_timer_timeout() -> void:
	yang_part.emitting = false
	yin_part.emitting = false

func trans_in():
	rotation = 0
	get_tree().create_tween().tween_property(self, "position", Vector2(127,80), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
func trans_out(winner: bool):
	if winner:
		laugh()
	else:
		spin(-.5,0)
		position.y += 12
		get_tree().create_tween().tween_property(self, "position", Vector2(127,-80), 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		$"../Yin2".value = 0
		$"../Yang2".value = 0

func spin(dir, amt):
	await get_tree().process_frame
	if amt < 10000:
		rotation += dir
		amt += 1
		spin(dir, amt)
		
func mark(who : bool):
	if who: #yang
		yang_part.emitting = true
		rotation -= .001
		yang.scale += Vector2(.0001,.0001)
		$"../Yang2".value += 1
		#$"../Yang2".position.y -= .001
	else: #yin
		yin_part.emitting = true
		rotation += .001
		yin.scale += Vector2(.0001,.0001)
		$"../Yin2".value += 1
		#$"../Yin2".position.y -= .001
	
func laugh():
	Music.stop()
	dead = true
	$LaughDeath.start()
	$LaughAudio.play()
	laughing()

var open_mouth = false
func laughing():
	open_mouth = !open_mouth
	if open_mouth:
		await get_tree().create_timer(.2).timeout
	else:
		await get_tree().create_timer(.806).timeout
	laughing()

func _process(delta: float) -> void:
	$"../Yin2".position.y = lerp($"../Yin2".position.y, position.y, delta * 12)
	$"../Yang2".position.y = lerp($"../Yang2".position.y, position.y, delta * 12)
	
	
	yin.scale = yin.scale.lerp(Vector2.ONE * 0.086, delta * 102)
	yang.scale = yang.scale.lerp(Vector2.ONE * 0.086, delta * 102)
	
	if dead:
		yang.position = yang.position.lerp(Vector2.ZERO, delta * 12)
		yin.position= yin.position.lerp(Vector2.ZERO, delta * 12)
		yang.position.x += delta * randf_range(-100,100)
		yin.position.x += delta * randf_range(-100,100)
		
		if open_mouth:
			yang.position.x += -120 * delta
			yin.position.x += 120 * delta
		
		rotation += delta

func _on_laugh_death_timeout() -> void:
	get_tree().quit()
