extends Line2D
class_name VisualFollowLine
## HOW TO USE
# call the spawn_line function every frame to start displaying it, or call it whenever you want a new line
# you can change the width curve color fill, etc in the line settings to give it a unique look
# use the export variables to change more properties

@export var wiggle : float = 0.1
@export var delete_oldest_point_time : float = 4.0

func spawn_line(pos : Vector2):
	add_point(to_local(pos + Vector2(randf_range(-wiggle,wiggle), randf_range(-wiggle, wiggle))))
	
	await get_tree().create_timer(delete_oldest_point_time).timeout
	if get_point_count() > 0:remove_point(0)
