extends MultiplayerSynchronizer
class_name InputComponent

const Direction = preload("res://utility/helpers/direction.gd")

@onready var player = $".."
@onready var pause_menu = %PauseMenu
@onready var camera_pivot = $"../CameraPivot"
@onready var camera = $"../CameraPivot/Camera3D"

# Camera control constants
const MOUSE_SENSITIVITY = 0.002
const MIN_CAMERA_ROTATION = -0.6  # Looking up limit
const MAX_CAMERA_ROTATION = 0.9   # Looking down limit
const DEFAULT_CAMERA_DISTANCE = 0.5  # Default distance from pivot
const MIN_CAMERA_DISTANCE = 0.2		# Closest distance when looking down

var look_direction := Vector3.BACK

var input_direction := Vector3.ZERO
var input_jump := false
var input_push := false
var input_run := false
var input_cast := false

const INPUT_ACTIONS = {
	"run": "input_run",
	"jump": "input_jump",
	"push": "input_push",
	"cast": "input_cast",
}

var is_paused = false

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _physics_process(_delta):
	input_direction = _handle_input_direction() # This makes input_direction accessible by authority client
	send_input_direction.rpc_id(1, input_direction)

	for action_name in INPUT_ACTIONS:
		if Input.is_action_just_pressed(action_name):
			send_input_state.rpc_id(1, action_name, true)
		elif Input.is_action_just_released(action_name):
			send_input_state.rpc_id(1, action_name, false)


	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func _handle_input_direction():
	var raw_input = Input.get_vector("left", "right", "up", "down")
	var raw_input_length = raw_input.length()
	var direction
	
	if raw_input_length > 0.1:
		look_direction = Vector3(raw_input.x, 0, raw_input.y)
		direction = Direction.look_direction_to_world_direction(look_direction, owner)

	else:
		direction = Vector3.ZERO
	
	return direction



func _unhandled_input(event):
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotate player horizontally (around Y axis)
		player.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# look_direction = -player.global_transform.basis.z.normalized()
		# if look_direction.length() > 0.1:
		# 	look_direction = -player.global_transform.basis.z
		# 	look_direction = look_direction.normalized()
			
		# camera_pivot.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Rotate camera vertically with proper clamping
		var current_rotation = camera_pivot.rotation.x
		var new_rotation = clamp(current_rotation - event.relative.y * MOUSE_SENSITIVITY, 
							MIN_CAMERA_ROTATION, MAX_CAMERA_ROTATION)
		camera_pivot.rotation.x = new_rotation
		
		# Adjust camera distance based on rotation
		_adjust_camera_distance(new_rotation)

# Adjust camera distance based on rotation angle
func _adjust_camera_distance(rotation_angle):
	# Calculate how far down we're looking (0 to 1 range)
	var look_down_factor = (rotation_angle - MIN_CAMERA_ROTATION) / (MAX_CAMERA_ROTATION - MIN_CAMERA_ROTATION)
	look_down_factor = clamp(look_down_factor, 0.0, 1.0)
	
	# Only adjust distance when looking below horizontal (positive rotation)
	if rotation_angle > -30:
		# Calculate new distance (closer when looking down)
		var new_distance = lerp(DEFAULT_CAMERA_DISTANCE, MIN_CAMERA_DISTANCE, look_down_factor)
		
		# Apply new distance to camera's z position
		var camera_transform = camera.transform
		camera_transform.origin.z = new_distance
		camera.transform = camera_transform
	else:
		# Reset to default distance when looking up
		var camera_transform = camera.transform
		camera_transform.origin.z = DEFAULT_CAMERA_DISTANCE
		camera.transform = camera_transform

@rpc("any_peer")
func send_input_direction(direction):
	input_direction = direction

@rpc("any_peer")
func send_input_state(action_name, is_pressed):
	var state_var = INPUT_ACTIONS[action_name]
	if state_var:
		set(state_var, is_pressed)
	else:
		# TODO: Should be able to remove this check
		print("Warning: Unknown input action: " + action_name)

func leave_game():
	multiplayer.multiplayer_peer.close()
	queue_free()
	GameManager.LeaveGame()

func toggle_pause():
	is_paused = !is_paused
	
	if is_paused:
		# Show pause menu
		pause_menu.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		pause_menu.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
