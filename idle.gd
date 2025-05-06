extends State

func Enter():
	print("Enter Idle")
	animation.play(self.name + "_down")
	# animation.set_direction(self.name, input.direction)
	
func Exit():
	print("Exit Idle")
	pass
	
func Update(_delta:float):
	pass
	# print("Update Idle")
	# input.parse_input_action()
	# animation.set_direction(self.name, input.direction)
	#
	# if !input.direction:
	# 	owner.idle.emit()
	#
	# state_movement()
	#
func state_movement():
	print("Idle: State Movement")
	# owner.velocity.x = input.direction.x * owner.run_speed
	# owner.velocity.y = input.direction.y * owner.run_speed
