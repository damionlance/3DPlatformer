extends Node

var stars = {"Atop the Mountain": false, "Down the Lazy River": false, "Pipes!": false}
var time_start

var WORLD_COLLECTIBLES : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	time_start = Time.get_unix_time_from_system()
	var file = FileAccess.open("user://temp_save.res", FileAccess.READ)
	var json_object = JSON.new()
	var data = json_object.parse(file.get_as_text())
	file.close()
	if typeof(data) == TYPE_DICTIONARY:
		WORLD_COLLECTIBLES = data

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	pass
