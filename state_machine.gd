extends MultiplayerSynchronizer
class_name FiniteStateMachine

var states : Dictionary = {}
var state_transitioning : bool = false
var current_state_name = ""

@onready var current_state = get_children()[0]



@export var input: InputComponent
@export var animation: AnimationTree

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)
	# TODO: Make this unnecessary
	current_state_name = current_state.name
	# await owner.ready
	# if owner.initial_state:
	# 	#call_deferred('_init_state')
	# 	_init_state()
	# 	current_state = owner.initial_state

# func _init_state():
# 	owner.initial_state.Enter()

func  _physics_process(delta): # TODO: Should this be _physics or just _process
	# if current_state:
	if state_transitioning:
		push_warning('StateMachine update called while transitioning')
	current_state.Update(delta)
	
func change_state(source_state : State, new_state_name : String, params = null):
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
		current_state.Exit()
		
	#print_debug('Entering ' + new_state_name) # For debugging state changes
	if params != null:
		new_state.Enter(params)
	else:
		new_state.Enter()
	current_state = new_state
	state_transitioning = false

	current_state_name = current_state.name
