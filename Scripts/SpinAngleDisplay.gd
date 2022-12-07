extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _draw():
	var angle_from = 0
	var angle_to = angle_from + get_parent().get_parent().spin_jump_angle
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(position)
	var colors = PoolColorArray([Color.yellow])
	
	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - 90
		points_arc.push_back(position + Vector2(cos(angle_point), sin(angle_point)) * 100)
	draw_polygon(points_arc, colors)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	pass
