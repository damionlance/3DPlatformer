extends Node
var time : float = 0

func _process(delta: float) -> void:
	time += delta

func _get_current_time() -> String:
	var minutes = time/60
	var seconds = fmod(time, 60)
	var milliseconds = fmod(time, 1) * 100
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
