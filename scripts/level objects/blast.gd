extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player":
		body.state.velocity.y = 25
		body.velocity.y = 25
		body.state.snap_vector = Vector3.ZERO
		body.state.jump_state = body.state.spin_jump
		body.state.update_state("Falling")
