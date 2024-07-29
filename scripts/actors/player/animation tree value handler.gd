extends AnimationTree
@onready var player := get_parent()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	set("parameters/Walk/blend_position", player.movement_direction.length())
	set("parameters/Run/blend_position", player.movement_direction.length())
	set("parameters/Crouch/blend_position", player.movement_direction.length())
	set("parameters/Wall Hang/blend_position", Input.get_vector("Left", "Right", "Backward", "Forward"))
	set("parameters/Ledge Hang/blend_position", Input.get_axis("Left", "Right"))
	set("parameters/Rope Climb/blend_position", Input.get_axis("Backward", "Forward"))
	#set("parameters/StateMachine/Grounded Animations/walk/blend_position", player.movement_direction.length())
	#set("parameters/StateMachine/Grounded Animations/run/blend_position", player.movement_direction.length())
	#set("parameters/StateMachine/Grounded Animations/Crouch/blend_position", player.movement_direction.length())
