extends CharacterBody3D


const SPEED = 5.0
@onready var state = $StateMachine
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	add_to_group("scared of rubbish")

func _physics_process(delta):
	set_velocity(velocity)
	move_and_slide()

func _on_damaged_dead():
	queue_free()
