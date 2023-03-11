extends Node3D

@export var destination = 0
# 0 = Pool level
# 1 = Pool Act. 2

var levels = ["res://TestLevels/Levels/newerPool.tscn", "res://TestLevels/Levels/poolAct2.tscn"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	print("here")
	if body.get_name() == "Player":
		get_tree().change_scene_to_file(levels[destination])
