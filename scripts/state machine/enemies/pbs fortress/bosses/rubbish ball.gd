extends RigidBody3D

var current_level := 0

var collider
var visual

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("holdable")
	add_to_group("heavy")
	collider = $"CollisionShape3D"
	visual = $"CSGSphere3D"
	increase_size()

func destroy():
	queue_free()

func increase_size():
	current_level += 1
	visual.radius = 0.25 * current_level
	collider.shape.radius = 0.25 * current_level


func _on_body_entered(body):
	if body.is_in_group("scared of rubbish") and body.state._current_state.state_name != "Damaged":
		body.state.HP -= current_level
		body.state.update_state("Damaged")
		destroy()
	elif body.name != "Player":
		destroy()
