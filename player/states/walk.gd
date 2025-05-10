extends State

func update_server(delta:float):
	input_dir = %InputComponent.input_direction
	input_run = %InputComponent.input_run
	input_jump = %InputComponent.input_jump
	input_push = %InputComponent.input_push

	if input_jump:
		state_machine.change_state.emit("jump")
	if input_push:
		state_machine.change_state.emit("push")
	if !input_dir:
		state_machine.change_state.emit("idle")
	else:
		if input_run:
			state_machine.change_state.emit("run")
	
	state_movement(delta)

