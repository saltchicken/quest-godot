extends State

# var jumping = false
# var jumping_duration = 0.1
# var jumping_timer = 0.0

func enter_server(_state_packet):
	owner.velocity.y += 2.0

	# jumping = true
	# jumping_timer = jumping_duration

func update_server(_delta:float):
	input_dir = %InputComponent.input_direction
	input_run = %InputComponent.input_run
	# var input_jump = %InputComponent.input_jump
	# if jumping_timer > 0:
	# 	jumping_timer -= _delta
	# 	if jumping_timer <= 0:
	# 		jumping = false

	if owner.is_on_floor():
		if input_dir.length() > 0.1:
			if input_run:
				state_machine.change_state.emit("run")
			else:
				state_machine.change_state.emit("walk")
		else:
			state_machine.change_state.emit("idle")
