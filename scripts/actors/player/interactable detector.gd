extends Area3D

@onready var player = get_parent()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Jump") and get_overlapping_areas().size() == 1 and not player.character_paused:
		player.state_chart.set_expression_property("locked_in_dialogue", not player.state_chart.get_expression_property("locked_in_dialogue"))
		if get_overlapping_areas()[0].has_method("_activate"):
			get_overlapping_areas()[0]._activate()

func _on_area_entered(area: Area3D) -> void:
	player.state_chart.set_expression_property("in_interactable", true)
	player.state_chart.set_expression_property("locked_in_dialogue", false)
	


func _on_area_exited(area: Area3D) -> void:
	player.state_chart.set_expression_property("in_interactable", false)
