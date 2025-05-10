extends Node


static func look_direction_to_world_direction(look_dir, rotated_owner):
	var input_rot = rotated_owner.global_rotation.y
	var forward = Vector2(0, 1).rotated(-input_rot)
	var right = Vector2(1, 0).rotated(-input_rot)

	var direction = right * look_dir.x + forward * look_dir.z
	
	# Combine them based on input
	return Vector3(direction.x, 0, direction.y).normalized()

