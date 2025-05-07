extends CharacterBody3D

enum Role {SERVER, AUTHORITY_CLIENT, PEER_CLIENT}
var role = Role.PEER_CLIENT

@onready var camera = $CameraPivot/Camera3D
@onready var player_name_label = %PlayerNameLabel

@onready var state_machine = $StateMachine

var _is_on_floor = false
var _alive = true

const SPEED = 2.5
const RUN_SPEED = 4.2
const FRICTION = 0.2

func debug(message):
	print("%s: %s" % [name, message])

func _enter_tree():
	%InputComponent.set_multiplayer_authority(name.to_int())

func _ready_server():
	add_to_group("players")
	var lava_areas = get_tree().get_nodes_in_group("lava")
	for lava in lava_areas:
		lava.body_entered.connect(_on_lava_entered)

func _ready_authority_client():
	add_to_group("players")
	GameManager.game_state_changed.connect(_on_game_state_changed)
	PingManager.ping_updated.connect(_on_ping_updated)
	camera.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _ready_peer_clients():
	add_to_group("players")
	GameManager.game_state_changed.connect(_on_game_state_changed)


func _physics_process_server(delta):
	_is_on_floor = is_on_floor()
	if _alive:
		_apply_movement_from_input(delta)

func facing_direction_vector_to_ordinal(direction_vector, player_forward=Vector3.ZERO):
	var forward = Vector3(0, 0, -1)
	if player_forward.length() > 0.1:
		forward = player_forward
	# var player_forward = -global_transform.basis.z.normalized()
	var angle_rad = forward.signed_angle_to(direction_vector, Vector3.UP)

	if angle_rad >= -PI / 4 and angle_rad < PI / 4:
		return "forward"
	elif angle_rad >= PI / 4 and angle_rad < 3 * PI / 4:
		return "left"
	elif angle_rad >= 3 * PI / 4 or angle_rad < -3 * PI / 4:
		return "backward"
	else:
		return "right"

func facing_direction_vector_to_ordinal2(direction_vector, player_forward=Vector3.ZERO):
	var forward = Vector3(0, 0, -1)
	if player_forward.length() > 0.1:
		forward = player_forward
	# var player_forward = -global_transform.basis.z.normalized()
	var angle_rad = forward.signed_angle_to(direction_vector, Vector3.UP)

	if angle_rad >= -PI / 4 and angle_rad < PI / 4:
		return "backward"
	elif angle_rad >= PI / 4 and angle_rad < 3 * PI / 4:
		return "left"
	elif angle_rad >= 3 * PI / 4 or angle_rad < -3 * PI / 4:
		return "forward"
	else:
		return "right"

func _physics_process_authority_client(_delta):
	# var player_forward = -global_transform.basis.z.normalized()
	%AuthorityLookDir.text = "Input: " + str(%InputComponent.look_direction)
	%AuthorityState.text = "State: " + str(%StateMachine.current_state)
	var animation_direction = facing_direction_vector_to_ordinal(%InputComponent.look_direction)
	%StateMachine.current_state.animation.play(%StateMachine.current_state.name + "_" + animation_direction)
	# print(%InputComponent.look_direction)
	
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		pass

	_apply_animation_authority_client()

func _physics_process_peer_client(_delta):
	var player_forward = -global_transform.basis.z.normalized()
	%PeerState.text = "State: " + str(%StateMachine.current_state)


	var authority_player = _find_authority_player()
	if authority_player:
		var to_authority = authority_player.global_position - global_position
		to_authority.y = 0	# Project onto horizontal plane
		to_authority = to_authority.normalized()

		var auth_camera = authority_player.get_node_or_null("CameraPivot/Camera3D")
		if auth_camera:
			# var to_target_global = global_transform.origin - auth_camera.global_transform.origin
			# var to_target_local_to_pov = auth_camera.global_transform.basis.inverse() * to_target_global

			var to_auth_camera_global = auth_camera.global_transform.origin - global_transform.origin
			var to_pov_local_to_target = global_transform.basis.inverse() * to_auth_camera_global
			
			var animation_direction = facing_direction_vector_to_ordinal2(to_pov_local_to_target, Vector3(%InputComponent.look_direction.x, 0, %InputComponent.look_direction.z))
			%StateMachine.current_state.animation.play(%StateMachine.current_state.name + "_" + animation_direction)


	_apply_animation_peer_client()

func _apply_animation_authority_client():
	pass

func _apply_animation_peer_client():
	pass

func _find_authority_player():
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.name.to_int() == name.to_int():
			continue  # Skip self
		if player.role == Role.AUTHORITY_CLIENT:
			return player
	return null

func _change_state(new_state_name):
	if multiplayer.is_server():
		if state_machine.current_state.name == new_state_name:
			# print("Already in state: " + new_state_name)
			return
		state_machine.current_state.state_transition.emit(state_machine.current_state, new_state_name)
		broadcast_state_change.rpc(new_state_name)
	else:
		print("This is a problem")

@rpc("authority")
func broadcast_state_change(new_state_name):
	if not multiplayer.is_server():
		if state_machine.current_state.name == new_state_name:
			# print("Already in state: " + new_state_name)
			return
		state_machine.current_state.state_transition.emit(state_machine.current_state, new_state_name)
	else:
		print("This is also a problem")


func _apply_movement_from_input(delta):
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Get synchronized input from client
	var input_dir = %InputComponent.input_direction
	# var input_jump = %InputComponent.input_jump
	var input_run = %InputComponent.input_run
	
	if input_run:
		_change_state("run")
	else:
		_change_state("idle")

	# var input_jump = %InputSynchronizer.input_jump
	# var input_push = %InputSynchronizer.input_push

	
	# Handle jump
	# if input_jump and is_on_floor() and jump_cooldown_timer <= 0:
	# 	velocity.y = JUMP_VELOCITY
	# 	jump_cooldown_timer = JUMP_COOLDOWN
	# 	jump_animation_timer = JUMP_ANIMATION_DURATION
	#
	# # Update cooldown timers
	# if jump_cooldown_timer > 0:
	# 	jump_cooldown_timer -= delta
	# if push_cooldown > 0:
	# 	push_cooldown -= delta
	# if jump_animation_timer > 0:
	# 	jump_animation_timer -= delta
	# if push_animation_timer > 0:
	# 	push_animation_timer -= delta
	
	# Handle push attack
	# if input_push and push_cooldown <= 0:
	# 	perform_push_attack()
	# 	push_cooldown = PUSH_COOLDOWN_DURATION
	# 	push_animation_timer = PUSH_COOLDOWN_DURATION
	
	# if input_dir.length() > 0.1:
	# 	print("Movement detected")
	
	# Apply friction
	velocity.x *= (1.0 - FRICTION)
	velocity.z *= (1.0 - FRICTION)
	
	# Apply movement force
	var current_speed = SPEED
	if input_run:
		current_speed = RUN_SPEED
	
	if input_dir:
		velocity.x += input_dir.x * current_speed * delta * 10.0
		velocity.z += input_dir.z * current_speed * delta * 10.0
	
	# Cap horizontal speed
	var max_speed = current_speed * 1.2
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	if horizontal_velocity.length() > max_speed:
		horizontal_velocity = horizontal_velocity.normalized() * max_speed
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.y
	
	# Apply movement
	move_and_slide()

	# Set animation state based on server-side logic (without direction)
	# if not alive:
	# 	current_animation_base = "death"
	# 	animation_speed = 1.0
	# 	return
	#
	# # Handle push animation
	# if push_animation_timer > 0:
	# 	current_animation_base = "push"
	# 	animation_speed = 1.0
	# 	return
	#
	# # Handle jump animation
	# if jump_animation_timer > 0:
	# 	current_animation_base = "jump"
	# 	animation_speed = 1.0
	# 	return
		
	# Handle movement animations
	# if input_dir.length() > 0.1:
	# 	if input_run:
	# 		current_animation_base = "run"
	# 		animation_speed = 1.0
	# 	else:
	# 		current_animation_base = "walk"
	# 		animation_speed = 1.0
	# else:
	# 	current_animation_base = "idle"
	# 	animation_speed = 1.0

# func perform_push_attack():
# 	if not multiplayer.is_server():
# 		return
#
# 	# Get synchronized input from client
# 	var input_dir = %InputSynchronizer.input_dir
# 	var forward_direction = Vector3.ZERO
#
# 	if input_dir.length() > 0.1:
# 		# Use the input direction directly to determine push direction
# 		# Convert 2D input to 3D direction
# 		forward_direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
# 	else:
# 		# If no input direction, use the character's last known direction
# 		var direction_map = {
# 			"up": Vector3(0, 0, -1),
# 			"down": Vector3(0, 0, 1),
# 			"left": Vector3(-1, 0, 0),
# 			"right": Vector3(1, 0, 0)
# 		}
# 		forward_direction = direction_map[last_direction]
#
# 	# Find players in radius
# 	print(forward_direction)
# 	print(last_direction)
# 	var players = get_tree().get_nodes_in_group("players")
#
# 	for other_player in players:
# 		if other_player == self:
# 			continue
#
# 		# Calculate vector to other player (ignoring Y)
# 		var to_other = other_player.global_position - global_position
# 		var to_other_flat = Vector3(to_other.x, 0, to_other.z)
# 		var distance = to_other_flat.length()
#
# 		# Check if player is within push radius
# 		if distance < PUSH_RADIUS:
# 			# Calculate push direction (away from pusher)
# 			var push_dir = to_other.normalized()
# 			var final_push_dir = push_dir * PUSH_FORCE
# 			final_push_dir.y = 0
#
# 			# Apply push on server
# 			other_player.velocity += final_push_dir
# 			# Send RPC to client
# 			apply_push.rpc_id(int(other_player.name), final_push_dir)

# @rpc("authority")
# func apply_push(push_vector):
# 	velocity += push_vector
# 	print("Push received: " + str(push_vector))

func _on_lava_entered(body):
	if not multiplayer.is_server():
		return
	if body == self:
		_alive = false
		player_died.rpc()
		await get_tree().create_timer(3.0).timeout
		global_position = Vector3(0, 3, 0)	# Respawn position
		_alive = true
		player_respawned.rpc()

@rpc("authority")
func player_died():
	_alive = false
	print("Do stuff for player death")
	# animated_sprite.play("death")
	#
	# var tween = create_tween()
	# tween.tween_property(animated_sprite, "modulate", Color(0, 0, 0, 1), 2.0)
	#
	# if multiplayer.get_unique_id() == name.to_int():
	# 	%InputSynchronizer.set_process(false)
	# 	%InputSynchronizer.set_physics_process(false)

@rpc("authority")
func player_respawned():
	_alive = true
	print("Do stuff for player respawn")
	# animated_sprite.modulate = Color(1, 1, 1, 1)
	# animated_sprite.play("idle_down")
	# if multiplayer.get_unique_id() == name.to_int():
	# 	%InputSynchronizer.set_process(true)
	# 	%InputSynchronizer.set_physics_process(true)

func _on_ping_updated(ping_value):
	if multiplayer.get_unique_id() == name.to_int():
		%PingLabel.text = "Ping: " + str(ping_value) + "ms"

func _on_game_state_changed(key, _value):
	if key == "players":
		if GameManager.game_state.players.has(name):
			player_name_label.text = GameManager.game_state.players[name].name
		else:
			player_name_label.text = "Player " + name

func _ready():
	if multiplayer.is_server():
		role = Role.SERVER
	elif multiplayer.get_unique_id() == name.to_int():
		role = Role.AUTHORITY_CLIENT
	
	match role:
		Role.SERVER:
			_ready_server()
		Role.AUTHORITY_CLIENT:
			_ready_authority_client()
		Role.PEER_CLIENT:
			_ready_peer_clients()

func _physics_process(delta):
	# print("----------------------------------------")
	match role:
		Role.SERVER:
			_physics_process_server(delta)
			state_machine._physics_process_state_machine(delta)
		Role.AUTHORITY_CLIENT:
			_physics_process_authority_client(delta)
		Role.PEER_CLIENT:
			_physics_process_peer_client(delta)
