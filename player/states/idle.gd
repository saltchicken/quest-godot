extends State

func update_server(delta:float):
	input_dir = %InputComponent.input_direction
	input_run = %InputComponent.input_run
	input_jump = %InputComponent.input_jump
	input_push = %InputComponent.input_push
	input_cast = %InputComponent.input_cast

	if input_cast:
		state_machine.change_state.emit("cast")
		return
	if input_jump:
		state_machine.change_state.emit("jump")
		return
	if input_push:
		state_machine.change_state.emit("push")
		return
	
	if input_dir.length() > 0.1:
		if input_run:
			state_machine.change_state.emit("run")
		else:
			state_machine.change_state.emit("walk")
	

	state_movement(delta)

