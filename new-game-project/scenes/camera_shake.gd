extends Camera2D 
class_name CameraShake
#keep in mind they are TWO camera shake systems being used here
##often I like to make the camera global and then acess this via code, but for this example the camera will be instantiated here

@export var decay := .8 #How quickly shaking will stop [0,1].
var max_offset := Vector2(480*.01,272*.01) #this reduces how much your camera can shake
var max_roll = 0.01 #Maximum rotation in radians (use sparingly).
@onready var noise = preload("res://scenes/cam_noise.tres") #required, you can customize this noise to change shaking properties

var noise_y = 0 #Value used to move through the noise
var trauma := 0.0 #Current shake strength
@export var trauma_pwr := 2 #Trauma exponent. Use [2,3]
var jitter = Vector2.ZERO

var tension = 2 #this simulates the camera going back to its orignal position like an elastic spring
var damp = .1 #this changes how fast your camera resets to its original state
var target_pos = Vector2(0,0) # where to reset your position back to, its a variable that never changes
var shake_pos = Vector2(0,0) #this gets changed to simulate an offset 
var velocity = Vector2.ZERO #changes how fast your offset changes

func _ready():
	ignore_rotation = false #allows the camera to rotate
	randomize() #makes the random systems more random

func _process(delta):
	if trauma: 
		trauma = max(trauma - decay * delta, 0) 
		shake()
		
	var displacement = (target_pos - shake_pos) * delta    #distance to center
	velocity += (displacement * tension) - (velocity * damp)
	shake_pos += velocity + jitter
	
	offset = shake_pos #this is the property that moves the camera

func shake(): #random jitter
	var amt = pow(trauma, trauma_pwr)
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(noise.seed,noise_y)
	jitter.x = max_offset.x * amt * noise.get_noise_2d(noise.seed*2,noise_y)
	jitter.y = max_offset.y * amt * noise.get_noise_2d(noise.seed*3,noise_y)
	
	return jitter

func add_trauma(amount : float, direction : Vector2): #CALL THIS FUNCTION TO START THE SHAKE
	trauma = min(trauma + amount, 2.0) #for the regular camera shake motion
	velocity += direction #for the spring camera motion
	#noise.seed = randi()
