extends SubViewportContainer

# --- Persistent Canvas Data ---
var sub_viewport: SubViewport
var baked_canvas: TextureRect
var canvas_image: Image # The one and only image object that holds all the paint data.
var canvas_texture: ImageTexture # The texture used to display the canvas_image.

#region Setup
func _ready():
	# Safely access the SubViewport using get_node()
	sub_viewport = get_node("SubViewportInk")
	
	if sub_viewport:
		baked_canvas = sub_viewport.get_node("BakedCanvas")
		
		# NOTE: Ensure the SubViewport size is set to 256x192 in the Inspector!
		
		if baked_canvas:
			initialize_canvas()
		else:
			push_error("Setup Error: SubViewportInk must contain a 'BakedCanvas' TextureRect child.")
			set_process(false)
			return
	else:
		push_error("Setup Error: Could not find 'SubViewportInk' child.")
		set_process(false)
		return
#endregion

func _process(delta: float) -> void:
	if Input.is_action_pressed("click"):
		for i in 10:
			var viewport_local_pos = baked_canvas.get_local_mouse_position()
			
			var stamp_data: Image
			stamp_data = create_circle_image(16 / 2) 
			stamp_image(viewport_local_pos, Color.BLACK, stamp_data)

# This function runs ONCE to set up the blank canvas.
func initialize_canvas():
	var viewport_size = sub_viewport.size
	
	# 1. Create a new Image filled with the neutral color.
	canvas_image = Image.create(viewport_size.x, viewport_size.y, false, Image.FORMAT_RGBA8)
	canvas_image.fill(Color.WHITE)
	
	# 2. Create the persistent ImageTexture and assign it.
	canvas_texture = ImageTexture.create_from_image(canvas_image)
	baked_canvas.texture = canvas_texture
	
	# Ensure the BakedCanvas fills the viewport
	baked_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

#region --- Shape Generation Utility Functions ---
# These functions decouple the stamping logic from the shape creation.

# Function to create a circular shape
func create_circle_image(radius: int) -> Image:
	var size = radius * 2
	var center = Vector2(radius, radius)
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	# NOTE: Image.lock() is no longer required in Godot 4.5
	
	for y in range(size):
		for x in range(size):
			var dist_sq = center.distance_squared_to(Vector2(x, y))
			if dist_sq <= radius * radius:
				image.set_pixel(x, y, Color(1, 1, 1, 1)) 
			else:
				image.set_pixel(x, y, Color(0, 0, 0, 0)) 
	return image
#endregion

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
