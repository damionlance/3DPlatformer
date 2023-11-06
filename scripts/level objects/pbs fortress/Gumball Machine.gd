extends Node3D


# Called when the node enters the scene tree for the first time.

func _on_stomp_button_activate(body):
	$"Gumball Spawner".hold_object(load("res://scenes/enemies/pbs fortress/bosses/rubbish ball.tscn").instantiate())
	$"Gumball Spawner".current_object.breaks_on_ground = false
	$"Gumball Spawner".current_object.increase_size()
	$"Gumball Spawner".current_object.increase_size()
	$"Gumball Spawner".drop_object()

