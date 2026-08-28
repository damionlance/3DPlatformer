extends AnimationTree
@export var player : Player
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(_delta: float) -> void:
	set("parameters/Grounded Animations/blend_position", Vector2(0, 0))
	set("parameters/conditions/is_on_floor", player.is_on_floor())
	set("parameters/conditions/not_on_floor", not player.is_on_floor())
	set("parameters/conditions/dive", player.current_jump == 4)
	set("parameters/Grounded Animations/conditions/sliding", player.sliding)
	set("parameters/Grounded Animations/conditions/not_sliding", not player.sliding)

func reset_all_constrained_movements() -> void:
	set("parameters/conditions/constrained_movement", false)
	set("parameters/ConstrainedMovements/conditions/tightrope", false)
