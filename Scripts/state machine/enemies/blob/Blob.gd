extends CharacterBody3D

var properties := ["has_butt", "hydrophobic", "holdable", "heavy"]
@onready var zone = get_parent().get_path()
func _force_reset():
		queue_free()

func _ready():
	for property in properties:
		add_to_group(property)

#func _process(_delta):
func _physics_process(_delta):
	if get_parent().name == "HoldableObjectNode":
		return
	for body in $SoftSpot.get_overlapping_bodies():
		if not body.is_in_group("no_damage"):
			queue_free()
	velocity = $StateMachine.velocity
	move_and_slide()
	$StateMachine.velocity = velocity

func _throw(Velocity : Vector3):
	$StateMachine.velocity = velocity
