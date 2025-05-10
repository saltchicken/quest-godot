extends State

var casting = false
var casting_duration = 0.4
var casting_timer = 0.0


func enter_server(_state_packet):
	
	casting_timer = casting_duration
	casting = true
	GameManager.cast_projectile(owner.global_position, %InputComponent.look_direction, owner.PROJECTILE_SPEED)
	# check_for_bodies_in_area()

func update_server(delta:float):
	input_dir = %InputComponent.input_direction
	input_run = %InputComponent.input_run


	if casting_timer > 0:
		casting_timer -= delta
		if casting_timer <= 0:
			casting = false
	else:
		casting = false
		# if owner.is_on_floor() and !jumping:
		if owner.is_on_floor():
			if input_dir.length() > 0.1:
				if input_run:
					state_machine.change_state.emit("run")
				else:
					state_machine.change_state.emit("walk")
			else:
				state_machine.change_state.emit("idle")
	
	# state_movement(delta)

