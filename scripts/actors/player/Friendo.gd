extends CharacterBody3D

@onready var goal_location := get_parent()
@onready var player_location := get_parent().get_parent()
@onready var _state := get_node("../../StateMachine")
@onready var grapple_shape := $Grapple
@export var toss_friendo := false

var throwing := bool(false)

signal hit_wall(position)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	pass # Replace with function body.

func _physics_process(_delta):
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	velocity = velocity
	pass

func _on_StateMachine_throw_fella():
	throwing = true
	pass # Replace with function body.
