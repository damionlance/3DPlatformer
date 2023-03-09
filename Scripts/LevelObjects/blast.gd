extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player":
		body._state.velocity.y = 200
		body.velocity.y = 200
		body._state.snap_vector = Vector3.ZERO
		body._state._jump_state = body._state.spin_jump
		body._state.update_state("Falling")
		print("Blast " , body._state._jump_state)
