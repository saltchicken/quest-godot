extends Node
class_name FiniteStateMachine

var states : Dictionary = {}
var state_transitioning : bool = false

@onready var current_state = get_children()[0]

@export var input: InputComponent
@export var animation: AnimationTree

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)
	# await owner.ready
	# if owner.initial_state:
	# 	#call_deferred('_init_state')
	# 	_init_state()
	# 	current_state = owner.initial_state

# func _init_state():
# 	owner.initial_state.Enter()

func  _physics_process_state_machine(delta): # TODO: Should this be _physics or just _process
	# if current_state:
	if state_transitioning:
		push_warning('StateMachine update called while transitioning')
	current_state.update_server(delta)

func _physics_process_state_machine_authority_client(delta):
	# if current_state:
	if state_transitioning:
		push_warning('StateMachine update called while transitioning')
	current_state.update_authority_client(delta)

func _physics_process_state_machine_peer_client(delta):
	# if current_state:
	if state_transitioning:
		push_warning('StateMachine update called while transitioning')
	current_state.update_peer_client(delta)
	
func change_state(source_state : State, new_state_name : String):
	state_transitioning = true
	if source_state != current_state:
		print("Invalid change_state trying from: " + source_state.name + " but currently in: " + current_state.name)
		#This typically only happens when trying to switch from death state following a force_change
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		print("New state is empty")
		return

	if current_state:
		match owner.role:
			owner.Role.SERVER:
				var state_packet = current_state.exit_server()
				new_state.enter_server(state_packet)
			owner.Role.AUTHORITY_CLIENT:
				var state_packet = current_state.exit_authority_client()
				new_state.enter_authority_client(state_packet)
			owner.Role.PEER_CLIENT:
				var state_packet = current_state.exit_peer_client()
				new_state.enter_peer_client(state_packet)
	else:
		print("There was no current state. This shouldn't be possible")

	current_state = new_state
	state_transitioning = false
