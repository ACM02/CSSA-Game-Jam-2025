extends CharacterBody2D
class_name Rock

func try_push(push_vec: Vector2) -> bool:
	# Try moving the rock by the same motion vector
	var collision = move_and_collide(push_vec)

	# If no collision → successful push
	return collision == null
