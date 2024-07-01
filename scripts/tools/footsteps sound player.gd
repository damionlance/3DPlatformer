extends Node3D

func play_sound() -> void:
	var sound_tag = $"Ground Material Detector".material_tag
	if sound_tag != "":
		find_child(sound_tag).play()
