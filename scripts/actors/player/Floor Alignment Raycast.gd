extends RayCast3D

@onready var state_chart := $%StateChart

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_colliding():
		state_chart.send_event("align_to_ground")
	else:
		state_chart.send_event("stop_align_to_ground")
