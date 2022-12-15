extends KinematicBody

onready var goal_location := get_parent()
onready var hand_location := get_node("../../lilfella/Armature/Skeleton/RightHand")
onready var _state := get_node("../../StateMachine")
export var toss_friendo := false

var velocity := Vector3.ZERO
var move_speed := 5
var movement_direction
var movement_speed = 20

var throwing := false
var hit_wall := false

signal hit_wall(position)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	pass # Replace with function body.

func _physics_process(delta):
	if throwing:
		if toss_friendo:
			if is_on_wall() or is_on_ceiling():
				emit_signal("hit_wall", global_transform.origin)
				throwing = false
				return
			velocity += movement_direction * movement_speed
		else:
			translation = hand_location.global_transform.origin
	else:
		if translation.distance_to(goal_location.global_transform.origin) > .5:
			var friendoPos = global_transform.origin
			var goalPos = goal_location.global_transform.origin
			
			velocity = (goalPos - friendoPos) * move_speed
		else:
			velocity = Vector3.ZERO
	if not hit_wall:
		velocity = move_and_slide(velocity, Vector3.UP)
	pass

func _on_StateMachine_throw_fella():
	throwing = true
	velocity = Vector3.ZERO
	movement_direction = _state.move_direction
	pass # Replace with function body.
