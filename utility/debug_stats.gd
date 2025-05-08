extends Node3D

@export var spacing: float = 0.25
@export var vertical: bool = true

@onready var authority_debug = %AuthorityDebug
@onready var peer_debug = %PeerDebug

func _ready():
	await owner.ready
	if not is_authority_client():
		authority_debug.visible = false
		peer_debug.visible = true
		reposition_children(peer_debug)
	else:
		peer_debug.visible = false
		authority_debug.visible = true
		reposition_children(authority_debug)

func is_authority_client():
	var parent = get_parent()
	return parent.role == parent.Role.AUTHORITY_CLIENT

func reposition_children(node):
	for i in range(node.get_child_count()):
		var child = node.get_child(i)
		var pos := Vector3.ZERO
		if vertical:
			pos.y = i * spacing  # Negative to stack downward
		else:
			pos.x = i * spacing
		child.position = pos
		child.billboard = BaseMaterial3D.BILLBOARD_ENABLED
