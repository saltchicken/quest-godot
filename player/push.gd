extends State

var pushing = false
var pushing_duration = 0.4
var pushing_timer = 0.0

func enter_server(_state_packet):
	print("Enter Server Push")

	pushing = true
	pushing_timer = pushing_duration


func exit_server():
	print("Exit Server Jump")
	return state_packet

func update_server(_delta:float):
	var input_dir = %InputComponent.input_direction
	var input_run = %InputComponent.input_run

	if pushing_timer > 0:
		pushing_timer -= _delta
		if pushing_timer <= 0:
			pushing = false

	else:
		# if owner.is_on_floor() and !jumping:
		if owner.is_on_floor():
			if input_dir.length() > 0.1:
				if input_run:
					state_machine.change_state.emit("run")
				else:
					state_machine.change_state.emit("walk")
			else:
				state_machine.change_state.emit("idle")
