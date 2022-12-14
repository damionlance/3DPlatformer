extends KinematicBody


onready var goal_location := get_parent()
var velocity := Vector3.ZERO
var move_speed := 5
# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	pass # Replace with function body.

func _physics_process(delta):
	if translation.distance_to(goal_location.global_transform.origin) > .5:
		var friendoPos = global_transform.origin
		var goalPos = goal_location.global_transform.origin
		
		velocity = (goalPos - friendoPos) * move_speed
	else:
		velocity = Vector3.ZERO
	velocity = move_and_slide(velocity, Vector3.UP)
	pass


