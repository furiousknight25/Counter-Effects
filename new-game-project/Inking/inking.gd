extends SubViewportContainer
class_name Inking
# --- Persistent Canvas Data ---
@onready var texture_rect: TextureRect = $SubViewportInk/TextureRect
@onready var tally: Panel = $Node2D/Tally
@onready var ying_tang_tally: Node2D = $Node2D/Tally/YingTangTally

const MONEY = preload("res://assets/money.png")

var sub_viewport: SubViewport
var canvas_image: Image # The one and only image object that holds all the paint data.
var canvas_texture: ImageTexture # The texture used to display the canvas_image.

@export var spray_speed = 10.0

var spray_spots

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_P):
		splat_bug()

#region Setup
func _ready():
	# Safely access the SubViewport using get_node()
	sub_viewport = get_node("SubViewportInk")
	
	if sub_viewport:if texture_rect:reset()
	
	SignalBus.connect("reset_ink", reset)
#endregion

#region --- Shape Generation Utility Functions ---
# These functions decouple the stamping logic from the shape creation.

# Function to create a circular shape
func create_circle_image(radius: int) -> Image:
	var size = radius * 2
	var center = Vector2(radius, radius)
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	for y in range(size):
		for x in range(size):
			var dist_sq = center.distance_squared_to(Vector2(x, y))
			if dist_sq <= radius * radius:
				image.set_pixel(x, y, Color(1, 1, 1, 1)) 
			else:
				image.set_pixel(x, y, Color(0, 0, 0, 0))
	return image

func spawned_spot(velocity: Vector2, position: Vector2, shape: Image, damping_speed: float, color: Color):
	if velocity.length_squared() < 0.1: return  # Use squared for better performance, this is the base case
	
	position += velocity
	velocity *= damping_speed
	stamp_image(position, color, shape) #spawn a blob at new point
	
	await get_tree().physics_frame #make sure its frame dependent
	
	spawned_spot(velocity, position, shape, damping_speed, color)
	
func splat_player(pos: Vector2, hit_dir: Vector2):
	SignalBus.emit_signal("switch_trail_color")
	for i in 12:
		spawned_spot(Vector2.UP.rotated(randf_range(-.5,.5)) * randf_range(1,40), pos, create_circle_image(randf_range(2,5)), .8, Color.BLACK)
	
	for i in 8:
		spawned_spot(-hit_dir.rotated(randf_range(-.3,.3)) * randf_range(1,30), pos, create_circle_image(randf_range(2,4)), .3, Color.BLACK)

func splat_ball(pos: Vector2, hit_dir: Vector2):
	for i in 20:
		spawned_spot(hit_dir.rotated(randf_range(-.5,.5)) * randf_range(1,35), pos, create_circle_image(randf_range(1,8)), randf_range(.2,.6), Color.WHITE)
	#endregion


func splat_bug():
	for i in 20:
		var circle = create_circle_image(randf_range(1,8))
		stamp_image(Vector2(randf_range(0,230), randf_range(0,180)), Color.WHITE, circle)

#region --- Main Reusable Stamping Function ---
# This high-performance function accepts any Image data for stamping.
func stamp_image(viewport_pos: Vector2, paint_color: Color, stamp_image_data: Image):
	if canvas_image == null:
		return
	var stamp_size = stamp_image_data.get_size()

	# --- PERFORMANCE STEP 1: Tint the stamp image (Localized CPU work) ---
	var tinted_stamp_image = stamp_image_data.duplicate()
	for y in range(stamp_size.y):
		for x in range(stamp_size.x):
			var pixel_color = tinted_stamp_image.get_pixel(x, y)
			if pixel_color.a > 0.05: 
				# Use the stamp's alpha but the team's RGB color
				tinted_stamp_image.set_pixel(x, y, Color(paint_color.r, paint_color.g, paint_color.b, pixel_color.a))

	# --- PERFORMANCE STEP 2: Blend the small image onto the master image ---
	# This only modifies memory for the area of the stamp.
	var draw_pos = viewport_pos - Vector2(stamp_size) / 2

	# Image.blend_rect is the fast, localized stamping call
	canvas_image.blend_rect(
		tinted_stamp_image, 
		Rect2(Vector2.ZERO, stamp_size), # Source (the stamp)
		Rect2(draw_pos, stamp_size).position # Destination on canvas
	)
	# --- PERFORMANCE STEP 3: Update the Texture (Localized GPU work) ---
	# This only uploads the changed pixels to the GPU VRAM.
	canvas_texture.update(canvas_image)
#endregion

func iterate_pixels():
	await Music.current_bar
	$Buildup.play()
	var final_image = canvas_image 
	var black_pixels = 0
	var white_pixels = 0
	ying_tang_tally.trans_in()
	# Step 2: Iterate through every pixel
	for y in range(clamp(final_image.get_height(), final_image.get_height() - 180, final_image.get_height() - 13)):
		await get_tree().physics_frame
		canvas_texture.update(canvas_image)
		tally.set_bw(black_pixels, white_pixels)
		for x in range(clamp(final_image.get_width(), final_image.get_width() - 245, final_image.get_width() -14 )):
			
			var color = final_image.get_pixel(x, y) # Get the color of the current pixel
			canvas_image.set_pixel(x, y, color.inverted());
			
			var brightness = color.v # v is the value part, which is brightness
			
			if brightness < 0.1: black_pixels += 1
			elif brightness > 0.9: white_pixels += 1
	
	
	
	Music.mute_perc_and_chop()
	if black_pixels > white_pixels:
		$Fail.play()
		ying_tang_tally
		
	else: 
		$Win.play()
		SignalBus.emit_signal("switch_scene", "shop")
	
	ying_tang_tally.trans_out(black_pixels > white_pixels)

func close():
	$SubViewportInk/AnimationPlayer.play('close')

func open():
	$SubViewportInk/AnimationPlayer.play('open')

func reset(image : Image = null):
	var viewport_size = sub_viewport.size
	
	if image == null:
		canvas_image = Image.create(viewport_size.x, viewport_size.y, false, Image.FORMAT_RGBA8)
		canvas_image.fill(Color.BLACK)
		
		# 2. Create the persistent ImageTexture and assign it.
		canvas_texture = ImageTexture.create_from_image(canvas_image)
	else:
		canvas_image = image
		canvas_texture = ImageTexture.create_from_image(canvas_image)
		
	texture_rect.texture = canvas_texture
	
	# Ensure the BakedCanvas fills the viewport
	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func shop(): # copy of the pixel thing
	var final_image = canvas_image 
	for y in range(final_image.get_height()):
		await get_tree().physics_frame
		canvas_texture.update(canvas_image)
		for x in range(final_image.get_width()):
			canvas_image.set_pixel(x,y,MONEY.get_pixel(x,y)) 
			#canvas_image.set_pixel(x,y,Color(sin(x), 0.502, 0.0, 1.0)) 


func _on_end_game_timer_timeout() -> void:
	iterate_pixels()
