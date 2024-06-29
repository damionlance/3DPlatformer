extends AnimationTree
@onready var player := get_parent()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	set("parameters/StateMachine/Grounded Animations/walk/blend_position", player.movement_direction.length())
	set("parameters/StateMachine/Grounded Animations/run/blend_position", player.movement_direction.length())
