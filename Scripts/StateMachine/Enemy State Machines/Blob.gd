extends CharacterBody3D

var properties := ["causes_damage", "has_butt", "hydrophobic"]

func _force_reset():
		queue_free()

func _ready():
	for property in properties:
		add_to_group(property)

#func _process(_delta):
func _physics_process(_delta):
	for body in $SoftSpot.get_overlapping_bodies():
		if not body.is_in_group("no_damage"):
			queue_free()
	velocity = $StateMachine.velocity
	move_and_slide()
