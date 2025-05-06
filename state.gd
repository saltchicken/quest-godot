
extends Node
class_name State

# TODO: Make this more dynamic like in topdown-godot
@onready var input = get_parent().get_node_or_null("InputComponent")
@onready var animation = get_parent().get_node_or_null("AnimatedSprite3D")

@warning_ignore("unused_signal")
signal state_transition

#func Enter(): # TODO: How to make this active
	#pass
	
func Exit():
	pass
	
func Update(_delta:float):
	pass
	
func state_movement():
	pass
