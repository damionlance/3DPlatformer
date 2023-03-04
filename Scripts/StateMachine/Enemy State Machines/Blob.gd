extends CharacterBody3D

var causes_damage = true

#func _process(_delta):
func _physics_process(_delta):
	for body in $SoftSpot.get_overlapping_bodies():
		queue_free()
	velocity = $StateMachine.velocity
	move_and_slide()
