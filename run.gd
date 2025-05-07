extends State

func Enter():
	# animation.set_direction(self.name, input.direction)
	print("Enter Run")
	
func Exit():
	print("Exit Run")
	pass
	
func Update(delta:float):
	var input_dir = %InputComponent.input_direction
	var input_run = %InputComponent.input_run
	
	if !input_dir:
			owner.change_state.emit("idle")
	else:
		if !input_run:
			owner.change_state.emit("walk")

	owner.velocity.x *= (1.0 - owner.FRICTION)
	owner.velocity.z *= (1.0 - owner.FRICTION)

	var current_speed = owner.SPEED
	if input_run:
		current_speed = owner.RUN_SPEED
	
	if input_dir:
		owner.velocity.x += input_dir.x * current_speed * delta * 10.0
		owner.velocity.z += input_dir.z * current_speed * delta * 10.0
	
	# Cap horizontal speed
	var max_speed = current_speed * 1.2
	var horizontal_velocity = Vector2(owner.velocity.x, owner.velocity.z)
	if horizontal_velocity.length() > max_speed:
		horizontal_velocity = horizontal_velocity.normalized() * max_speed
		owner.velocity.x = horizontal_velocity.x
		owner.velocity.z = horizontal_velocity.y

func state_movement():
	print("Run: State Movement")
	# owner.velocity.x = input.direction.x * owner.run_speed
	# owner.velocity.y = input.direction.y * owner.run_speed
