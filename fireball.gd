extends RigidBody3D

var direction = Vector3.FORWARD
var speed = 10.0

func _ready() -> void:
	apply_impulse(direction * speed)
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(queue_free)
