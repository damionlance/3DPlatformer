extends Node3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VelocityTrigger_velocity_trigger_fired(body):
	if body.name == "Player":
		body._state.velocity.y = 100
		body.velocity.y = 100
		body._state.snap_vector = Vector3.ZERO
		body._state.update_state("Falling")
		body._state._jump_state = body._state.jump
	pass # Replace with function body.
