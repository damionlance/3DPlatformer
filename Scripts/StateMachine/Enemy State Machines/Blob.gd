extends CharacterBody3D

func _process(_delta):
	for body in $SoftSpot.get_overlapping_bodies():
		if body.velocity.y < -10:
			queue_free()

func _physics_process(delta):
	velocity = $StateMachine.velocity
	move_and_slide()