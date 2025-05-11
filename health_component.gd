class_name HealthComponent extends Node

@export var MAX_HEALTH := 100.0
@export var state_machine: FiniteStateMachine
var health : float : set = _set_health

@onready var resistances = owner.get_node_or_null("DefenseProfileComponent")

# signal health_update

func _set_health(new_value):
	if new_value > MAX_HEALTH:
		new_value = MAX_HEALTH
	health = new_value
	if health <= 0.0:
		health = 0.0
		if state_machine.current_state.name != "death":
			print("Emit death")
			state_machine.change_state.emit("death")
		else:
			print("Player already dead")

	# health_update.emit()
	

var i_frames = 0.0

func _ready():
	health = MAX_HEALTH
	
func _physics_process(delta: float) -> void:
	i_frame_handler(delta)

func i_frame_handler(delta):
	i_frames -= delta
	if i_frames < 0.0:
		i_frames = 0.0
		
func add_health(health_to_add):
	health += health_to_add
	
func full_health():
	health = MAX_HEALTH

func kill():
	health = 0.0

func damage(damage_amount):
	show_hit_indicator.rpc(str(damage_amount))
	health -= damage_amount

# func damage(attack: Attack):
# 	var damage = attack.attack_damage
# 	#print(attack.attack.attack_type)
# 	if resistances != null:
# 		damage = resistances.apply(attack)
# 	if health <= 0:
# 		push_warning("Should be dead already. Emitting despawn. This shouldn't happen")
# 		if state_machine.current_state.name != "death":
# 			owner.despawn.emit()
# 			push_warning("Fixed the death issue. Investigate")
# 		return
# 	if state_machine:
# 		if state_machine.current_state.name not in ["hit", "death"] and i_frames <= 0.0:
# 			health -= damage
# 			hit_indicator(owner, str(damage))
# 			Global.hit_stop(0.15)
# 			if health <= 0:
# 				owner.death.emit()
# 				if attack.attacker is Player:
# 					attack.attacker.profile.experience += owner.experience
# 			else:
# 				owner.hit.emit(attack)
# 	else:
# 		push_warning("StateMachine not set")


var hit_indicator_node = preload("res://hit_indicator.tscn")

@rpc("authority")
func show_hit_indicator(damage_text: String):
	if multiplayer.is_server():
		print("Don't run on server")
		return

	var hit_indicator_instance = hit_indicator_node.instantiate()
	owner.add_child(hit_indicator_instance)
	hit_indicator_instance.set_text(damage_text)

	if owner.role == owner.Role.AUTHORITY_CLIENT:
		hit_indicator_instance.main()
		return
	if owner.role == owner.Role.PEER_CLIENT:
		var authority_player = _find_authority_player()
		if authority_player and authority_player != owner:
			var auth_camera = authority_player.get_node_or_null("CameraPivot/Camera3D")
			if auth_camera:
				# Make the hit indicator face the authority camera
				var direction = auth_camera.global_transform.origin - hit_indicator_instance.global_transform.origin
				
				# Make the hit indicator face away from the camera (opposite direction)
				hit_indicator_instance.look_at(hit_indicator_instance.global_transform.origin - direction, Vector3.UP)
		hit_indicator_instance.main()
		return
	

func _find_authority_player():
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.role == player.Role.AUTHORITY_CLIENT:
			return player
	return null

# func hit_indicator(parent_node, text_info: String, x_offset: float = 0.0, y_offset: float = 1.0):
# 	var hit_indicator_instance = hit_indicator_node.instantiate()
# 	parent_node.add_child(hit_indicator_instance)
# 	hit_indicator_instance.set_text(text_info)
# 	hit_indicator_instance.x_offset = x_offset
# 	hit_indicator_instance.y_offset = y_offset
# 	hit_indicator_instance.main()
