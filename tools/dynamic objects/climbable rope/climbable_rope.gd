@tool
class_name ClimbableRope extends MovementRestrictiveRope


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement_constraint.type = str(get_script().get_global_name())
	movement_constraint.direction = (anchor.global_position - global_position).normalized()
	movement_constraint.anchor_pos = anchor.position
	anchor.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if old_anchor != anchor.position :
			old_anchor = anchor.position
			update_length()
			update_rotation()

func update_rotation() -> void:
	if anchor.position * Vector3(1,0,1) == Vector3.ZERO:
		mesh.rotation = Vector3.ZERO
		return
	mesh.look_at(anchor.global_position, Vector3.UP, true)
	mesh.rotate_object_local(Vector3(1,0,0), PI*0.5)

## Called in-editor when changes are made to the tightrope. Updates mesh and colliders.
## Ropes should not be changed during runtime.
func update_length() -> void:
	if mesh == null:
		return
	
	mesh.position = (old_anchor) * 0.5
	mesh.mesh.height = (old_anchor).length()
	
	collision_shape.shape.height = (old_anchor).length()
