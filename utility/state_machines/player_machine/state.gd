
extends Node
class_name State

# TODO: Make this more dynamic like in topdown-godot
@onready var input = get_parent().get_node_or_null("InputComponent")
@onready var animation = get_parent().animation

@onready var state_machine = get_parent() as FiniteStateMachine

@warning_ignore("unused_signal")
signal state_transition


var _authority_player = null
var _auth_camera = null

var state_packet

func enter_server(_state_packet):
	pass

func enter_authority_client(_state_packet):
	animation.play(name)
	animation.set_direction(name, Vector2(%InputComponent.look_direction.x, %InputComponent.look_direction.z))
	# %StateMachine.current_state.animation.set_speed_scale(%StateMachine.current_state.name, 10.0)

func enter_peer_client(_state_packet):
	animation.play(name)
	animation.set_direction(name, get_rotated_vector())
	
func exit_server():
	return state_packet

func exit_authority_client():
	return state_packet

func exit_peer_client():
	return state_packet
	
func update_server(_delta:float):
	pass

func update_authority_client(_delta:float):
	%AuthorityLookDir.text = "Input: " + str(%InputComponent.look_direction)
	%AuthorityState.text = "State: " + str(%StateMachine.current_state)
	%StateMachine.current_state.animation.set_direction(%StateMachine.current_state.name, Vector2(%InputComponent.look_direction.x, %InputComponent.look_direction.z))

func update_peer_client(_delta:float):
	%PeerState.text = "State: " + str(%StateMachine.current_state)
	%StateMachine.current_state.animation.set_direction(%StateMachine.current_state.name, get_rotated_vector())

func _find_authority_player():
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.name.to_int() == name.to_int():
			continue  # Skip self
		if player.role == owner.Role.AUTHORITY_CLIENT:
			return player
	return null

func get_rotated_vector():
	if _authority_player == null:
		_authority_player = _find_authority_player()
		if _authority_player == null:
			return Vector2.ZERO
		_auth_camera = _authority_player.get_node_or_null("CameraPivot/Camera3D")

	# TODO: Should not need the if statements. Need to calculate the rotated vector properly for the direction
	var to_auth_camera_global = _auth_camera.global_transform.origin - owner.global_transform.origin
	var to_pov_local_to_target = owner.global_transform.basis.inverse() * to_auth_camera_global
	
	var angle_rad = %InputComponent.look_direction.signed_angle_to(to_pov_local_to_target, Vector3.UP)
	#
	var rotated_vector
	if angle_rad >= -PI/8 and angle_rad < PI/8:
		rotated_vector = Vector2(0, 1)		# N
	elif angle_rad >= PI/8 and angle_rad < 3*PI/8:
		rotated_vector = Vector2(-0.7, 0.7) # NW
	elif angle_rad >= 3*PI/8 and angle_rad < 5*PI/8:
		rotated_vector = Vector2(-1, 0)		# W
	elif angle_rad >= 5*PI/8 and angle_rad < 7*PI/8:
		rotated_vector = Vector2(-0.7, -0.7) # SW
	elif angle_rad >= 7*PI/8 or angle_rad < -7*PI/8:
		rotated_vector = Vector2(0, -1)		# S
	elif angle_rad >= -7*PI/8 and angle_rad < -5*PI/8:
		rotated_vector = Vector2(0.7, -0.7) # SE
	elif angle_rad >= -5*PI/8 and angle_rad < -3*PI/8:
		rotated_vector = Vector2(1, 0)		# E
	else: # angle_rad >= -3*PI/8 and angle_rad < -PI/8
		rotated_vector = Vector2(0.7, 0.7)	# NE

	return rotated_vector
func state_movement():
	pass
