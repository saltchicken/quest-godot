extends State

func enter_server(_params):
	print("Enter Idle")

func enter_process_authority_client(_params):
	pass

func enter_process_peer_client(_params):
	pass

func Exit():
	print("Exit Idle")

func Update(_delta:float):
	var input_dir = %InputComponent.input_direction
	var input_run = %InputComponent.input_run
	
	if input_dir.length() > 0.1:
		if input_run:
			owner.change_state.emit("run")
		else:
			owner.change_state.emit("walk")
	


	#
	# state_movement()
	#
# func state_movement():
# 	print("Idle: State Movement")
	# owner.velocity.x = input.direction.x * owner.run_speed
	# owner.velocity.y = input.direction.y * owner.run_speed
	#
	#	# Get synchronized input from client
