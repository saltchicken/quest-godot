extends RigidBody3D

var direction = Vector3.FORWARD
var speed = 10.0
var destruction_timer: SceneTreeTimer = null

var caster = null

func _ready() -> void:
    if multiplayer.is_server():
        gravity_scale = 0.0
        apply_impulse(direction * speed)
        
        # Store the timer reference so we can cancel it later
        destruction_timer = get_tree().create_timer(5.0)
        destruction_timer.timeout.connect(queue_free)

        %InteractionArea.body_entered.connect(_on_interaction_area_body_entered)

func _on_interaction_area_body_entered(body: Node) -> void:
    if not multiplayer.is_server():
        return
        
    # Skip if the body is itself or its own InteractionArea
    if body == self || body.get_parent() == self || body == caster:
        return
        
    if body is CharacterBody3D:
        print("Hit a character!")
        handle_hit()
    elif body is StaticBody3D:
        print("Hit a static object!")
        handle_hit()
    elif body is RigidBody3D:
        print("Hit another physics object!")
        handle_hit()

func handle_hit() -> void:
    # Cancel the existing timer
    if destruction_timer and destruction_timer.time_left > 0:
        # We can't directly cancel the timer, but we can disconnect our callback
        destruction_timer.timeout.disconnect(queue_free)
    
    # Optional: Play explosion effect or animation
    # play_explosion_effect()
    
    # Create a shorter timer for immediate destruction
    # This gives time for any effects to play before removing the object
    var quick_timer = get_tree().create_timer(0.1)
    quick_timer.timeout.connect(queue_free)
    
    # Disable physics to prevent further collisions
    freeze = true
    
    # Optionally, make it stop moving
    linear_velocity = Vector3.ZERO
    angular_velocity = Vector3.ZERO
