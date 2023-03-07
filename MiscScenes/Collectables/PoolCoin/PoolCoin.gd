extends Collectable


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.get_name() == "Player":
		collected = true
		Global.UPDATE_COLLECTIBLES(name, collected)
		if body.add_levelcoin(0):
			queue_free()
