
extends Node
class_name State

# TODO: Make this more dynamic like in topdown-godot
@onready var input = get_parent().get_node_or_null("InputComponent")
@onready var animation = get_parent().animation

@warning_ignore("unused_signal")
signal state_transition

var state_packet

func enter_server(_state_packet):
	pass

func enter_authority_client(_state_packet):
	pass

func enter_peer_client(_state_packet):
	pass
	
func exit_server():
	return state_packet

func exit_authority_client():
	return state_packet

func exit_peer_client():
	return state_packet
	
func Update(_delta:float):
	pass
	
func state_movement():
	pass
