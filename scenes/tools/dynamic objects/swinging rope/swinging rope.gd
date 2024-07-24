@tool
class_name SwingingRope extends DynamicRope

## Set the maximum angle the rope may reach in degrees.
@export var max_angle : float = 45

## Set the time the rope takes to swing from one side to the other.
@export var time_to_swing : float = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation.x = -deg_to_rad(max_angle)
	update_length()
	mesh_instance.rotation = Vector3.ZERO
	if not Engine.is_editor_hint():
		_swing()

func _swing() -> void:
	var tween := create_tween()
	tween.tween_property(self, "rotation:x", deg_to_rad(max_angle), time_to_swing).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation:x", -deg_to_rad(max_angle), time_to_swing).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(_swing)
