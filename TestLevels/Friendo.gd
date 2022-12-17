extends KinematicBody

onready var goal_location := get_parent()
onready var player_location := get_parent().get_parent()
onready var hand_location := get_node("../../lilfella/Armature/Skeleton/RightHand")
onready var _state := get_node("../../StateMachine")
onready var grapple_shape := $Grapple
export var toss_friendo := false

var velocity := Vector3.ZERO

var throwing := false
var hit_wall := false

signal hit_wall(position)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	pass # Replace with function body.

func _physics_process(delta):
	velocity = move_and_slide(velocity, Vector3.UP)
	pass

func _on_StateMachine_throw_fella():
	throwing = true
	pass # Replace with function body.
