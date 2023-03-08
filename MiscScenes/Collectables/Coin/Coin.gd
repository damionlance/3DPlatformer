extends Collectable

func _process(delta):
	
	pass


func _on_coin_body_entered(body):
	if body.get_name() == "Player":
		_update_collectables(true)
		if body.add_coin():
			queue_free()
