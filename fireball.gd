extends RigidBody3D

var direction = Vector3.FORWARD
var speed = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Apply initial velocity in the direction
	# linear_velocity = direction * speed * 100
	apply_impulse(direction * speed)
	# Optional: Add a timer to destroy the projectile after some time
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(queue_free)


func _process(_delta: float) -> void:
	# Optional: You can add additional effects here
	pass

