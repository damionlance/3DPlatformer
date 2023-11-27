extends Node3D

@onready var floor := $"Floor Raycast"

var is_on_floor := false
var collision_surface = null
var floor_extent := Vector3.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	floor_extent = floor.get_collision_point() - global_position if floor.is_colliding() else floor.target_position
	is_on_floor = true if floor_extent.y >= -1.01 else false
	collision_surface = floor.get_collider()
