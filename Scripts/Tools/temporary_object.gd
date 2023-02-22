extends RigidBody3D

var time_to_live := Timer.new()
var how_much := 0
# Called when the node enters the scene tree for the first time.
func _ready():
	time_to_live.wait_time = how_much
	time_to_live.autostart = true
	time_to_live.one_shot = true
	set_as_top_level(true)
	add_child(time_to_live)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if time_to_live.time_left <= 0:
		print("Hey")
		queue_free()
	pass
