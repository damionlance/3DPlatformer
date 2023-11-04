extends Button

var level_path

func _pressed():
	Global._delete_save()
	get_tree().change_scene_to_packed(load(level_path))
