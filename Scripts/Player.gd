extends KinematicBody

onready var spring_arm : SpringArm = $SpringArm
onready var player_model = $PlayerModel

var Velocity :=  Vector3.ZERO
var ClippingVector := Vector3.DOWN

func _ready():
	pass # Replace with function body.

func _process(delta):
	spring_arm.translation = translation

func _physics_process(delta):
	
	if Velocity.length() > 0.2:
		player_model.rotation.y = Vector2(Velocity.z, Velocity.x).angle()
	move_and_slide_with_snap(Velocity, ClippingVector, Vector3.UP, false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
