extends StaticBody2D

#ALL things that CAN be hit should have this function, the velocity is inputed if we want to measure speed, but mainly for directional particles when we get there
func hit(velocity : Vector2):
	queue_free()
