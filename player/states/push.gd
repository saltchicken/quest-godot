extends State

var pushing = false
var pushing_duration = 0.4
var pushing_timer = 0.0

var pushing_area


func enter_server(_state_packet):

	pushing_timer = pushing_duration

	pushing_area = %PushingArea
	# if not pushing_area.body_entered.is_connected(_on_interaction_area_body_entered):
	# 	pushing_area.body_entered.connect(_on_interaction_area_body_entered)
	# if not pushing_area.body_exited.is_connected(_on_interaction_area_body_exited):
	# 	pushing_area.body_exited.connect(_on_interaction_area_body_exited)
	# pushing_area.global_position = owner.global_position + owner.look_direction + Vector3.UP
	# pushing_area.global_rotation = owner.global_rotation
	
	pushing = true

	print(%InputComponent.look_direction)
	check_for_bodies_in_area()

func exit_server():
	return state_packet

func update_server(delta:float):
	input_dir = %InputComponent.input_direction
	input_run = %InputComponent.input_run

	if pushing_timer > 0:
		pushing_timer -= delta
		if pushing_timer <= 0:
			pushing = false

	else:
		pushing = false
		# if owner.is_on_floor() and !jumping:
		if owner.is_on_floor():
			if input_dir.length() > 0.1:
				if input_run:
					state_machine.change_state.emit("run")
				else:
					state_machine.change_state.emit("walk")
			else:
				state_machine.change_state.emit("idle")
	
	state_movement(delta)


func check_for_bodies_in_area():
	if pushing_area and pushing:
		var bodies = pushing_area.get_overlapping_bodies()
		for body in bodies:
			if body is RigidBody3D:
				if body.name == "TestBox" or body.name == "TestBox2" or body.name == "TestBox3":
					print("Found RigidBody in push area: ", body.name)
					owner.push_rigid_body_away(body, 2)
				pushing = false
			elif body is CharacterBody3D:
				print("Found CharacterBody in push area: ", body.name)
				owner.push_character_body(body, 3)
				pushing = false
			elif body is StaticBody3D:
				print("Found StaticBody in push area: ", body.name)
