extends State

var dead = false
var death_duration = 1.0
var death_timer = 0.0


func enter_server(_state_packet):

	print("Entering death")
	death_timer = death_duration
	dead = true
	owner.player_died.rpc()

func exit_server():
	return state_packet

func update_server(delta:float):
	if death_timer > 0:
		death_timer -= delta
		if death_timer <= 0:
			dead = false

	else:
		print("We alive")
		dead = false
		owner.global_position = Vector3(0, 3, 0)	# Respawn position
		owner.health_component.full_health()
		owner.player_respawned()
		state_machine.change_state.emit("idle")

