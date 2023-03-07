extends Collectable

func _process(delta):
	
	pass


func _on_coin_body_entered(body):
	if body.get_name() == "Player":
		collected = true
		Global.UPDATE_COLLECTIBLES(name, collected)
		if body.add_coin():
			queue_free()
