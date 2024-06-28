extends Area3D
class_name RespawnZone

var active_checkpoint : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active_checkpoint != null:
		print(active_checkpoint.global_position)
	pass
