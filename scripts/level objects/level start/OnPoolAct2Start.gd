extends LevelStart

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $Player.global_position.y < -10:
		get_tree().change_scene_to_file("res://TestLevels/Levels/newerPool.tscn")
	pass
