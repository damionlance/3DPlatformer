extends Camera3D

@onready var player = $"../../../Player"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
		look_at(player.global_position)
