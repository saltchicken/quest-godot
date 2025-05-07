extends State

func Enter():
	print("Enter Idle")
	# animation.set_direction(self.name, input.direction)
	
func Exit():
	print("Exit Idle")
	pass
	
func Update(_delta:float):
	pass
	var input_dir = %InputComponent.input_direction
	var input_run = %InputComponent.input_run
	

	owner.velocity.x *= (1.0 - owner.FRICTION)
	owner.velocity.z *= (1.0 - owner.FRICTION)

	if input_dir.length() > 0.1:
		if input_run:
			owner.run.emit()
		else:
			owner.walk.emit()
	


	#
	# state_movement()
	#
# func state_movement():
# 	print("Idle: State Movement")
	# owner.velocity.x = input.direction.x * owner.run_speed
	# owner.velocity.y = input.direction.y * owner.run_speed
	#
	#	# Get synchronized input from client
