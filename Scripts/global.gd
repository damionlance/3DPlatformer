extends Node

var stars = {"Atop the Mountain": false, "Down the Lazy River": false, "Pipes!": false}
var time_start

# Called when the node enters the scene tree for the first time.
func _ready():
	time_start = Time.get_unix_time_from_system()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
