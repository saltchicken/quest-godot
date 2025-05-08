extends State

# var jumping = false
# var jumping_duration = 0.1
# var jumping_timer = 0.0

func enter_server(_state_packet):
	owner.velocity.y += 2.0
	print("Enter Server Jump")

	# jumping = true
	# jumping_timer = jumping_duration


func exit_server():
	print("Exit Server Jump")
	return state_packet

func update_server(_delta:float):
	var input_dir = %InputComponent.input_direction
	var input_run = %InputComponent.input_run
	var input_jump = %InputComponent.input_jump
	# if jumping_timer > 0:
	# 	jumping_timer -= _delta
	# 	if jumping_timer <= 0:
	# 		jumping = false

	# if owner.is_on_floor() and !jumping:
	if owner.is_on_floor():
		if input_dir.length() > 0.1:
			if input_run:
				owner.change_state.emit("run")
			else:
				owner.change_state.emit("walk")
		else:
			owner.change_state.emit("idle")
	# if owner.is_on_floor():
	# 	owner.change_state.emit("idle")
	# var input_dir = %InputComponent.input_direction
	# var input_run = %InputComponent.input_run
	#
	# if input_dir.length() > 0.1:
	# 	if input_run:
	# 		owner.change_state.emit("run")
	# 	else:
	# 		owner.change_state.emit("walk")
	


	#
	# state_movement()
	#
# func state_movement():
# 	print("Idle: State Movement")
	# owner.velocity.x = input.direction.x * owner.run_speed
	# owner.velocity.y = input.direction.y * owner.run_speed
	#
	#	# Get synchronized input from client
