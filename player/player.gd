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

const PROJECTILE_SPEED = 25.0

func _enter_tree():
	%InputComponent.set_multiplayer_authority(name.to_int())

func _ready_server():
	add_to_group("players")

	# $InteractionArea.body_entered.connect(_on_interaction_area_body_entered)
	# $InteractionArea.body_exited.connect(_on_interaction_area_body_exited)

func _handle_sliding_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is StaticBody3D:
			if collision.get_collider().name == "Lava":
				print("Lava entered")
				_alive = false
				player_died.rpc()
				await get_tree().create_timer(3.0).timeout
				global_position = Vector3(0, 3, 0)	# Respawn position
				_alive = true
				player_respawned.rpc()
				return
				# Handle the collision with the static body

func _on_interaction_area_body_entered(body):
	if body is StaticBody3D:
		print("Player near StaticBody: ", body.name)

	if body is RigidBody3D:
		print("Pushing body")
		push_rigid_body_away(body, 3)
		# Handle the detection of the static body
		#
func _on_interaction_area_body_exited(body):
	if body is StaticBody3D:
		print("Player no longer near StaticBody: ", body.name)

	if body is RigidBody3D:
		print("Player no longer near RigidBody: ", body.name)

func push_character_body(body: CharacterBody3D, push_force: float = 5.0):
	if not multiplayer.is_server():
		return
	
	var direction = global_position - body.global_position
	direction.y = 0
	direction = direction.normalized() * -1

	var push_velocity = direction * push_force
	
	body.velocity += push_velocity

func push_rigid_body_away(body: RigidBody3D, push_force: float = 10.0):
	if not multiplayer.is_server():
		return
	
	var direction_from_player = global_position - body.global_position
	
	direction_from_player.y = 0
	direction_from_player = direction_from_player.normalized() * -1
	
	body.apply_impulse(direction_from_player * push_force)

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
		state_machine._physics_process_state_machine(delta)
		# Apply gravity
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.x *= (1.0 - FRICTION)
			velocity.z *= (1.0 - FRICTION)
		
		if move_and_slide():
			_handle_sliding_collisions()

func _physics_process_authority_client(_delta):
	state_machine._physics_process_state_machine_authority_client(_delta)

func _physics_process_peer_client(_delta):
	state_machine._physics_process_state_machine_peer_client(_delta)

@rpc("authority")
func player_died():
	_alive = false
	print("Do stuff for player death")
	# animated_sprite.play("death")
	#
	# var tween = create_tween()
	# tween.tween_property(animated_sprite, "modulate", Color(0, 0, 0, 1), 2.0)
	#
	# self.set_process(false)
	# self.set_physics_process(false)
	if multiplayer.get_unique_id() == name.to_int():
		%InputComponent.set_process(false)
		%InputComponent.set_physics_process(false)

@rpc("authority")
func player_respawned():
	_alive = true
	print("Do stuff for player respawn")
	# animated_sprite.modulate = Color(1, 1, 1, 1)
	# animated_sprite.play("idle_down")
	# self.set_process(true)
	# self.set_physics_process(true)
	if multiplayer.get_unique_id() == name.to_int():
		%InputComponent.set_process(true)
		%InputComponent.set_physics_process(true)

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
		Role.AUTHORITY_CLIENT:
			_physics_process_authority_client(delta)
		Role.PEER_CLIENT:
			_physics_process_peer_client(delta)
