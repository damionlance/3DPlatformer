extends AudioStreamPlayer



func _on_timer_timeout():
	play()
	$Timer.start(randi()%120)
	pass # Replace with function body.
