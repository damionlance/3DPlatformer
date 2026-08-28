@tool
class_name TightRope extends MovementRestrictiveRope

@export_category("Collision Adjustment")


#region base functions for TightRope
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	calculate_catenary_offsets()
	movement_constraint.type = str(get_script().get_global_name())
	movement_constraint.direction = (anchor.global_position - global_position).normalized()
	movement_constraint.anchor_pos = anchor.position
	anchor.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if old_anchor != anchor.position :
			old_anchor = anchor.position
			calculate_catenary_offsets()
			update_length()
			update_rotation()

func update_rotation() -> void:
	mesh.rotation.y = -Vector2(old_anchor.x, old_anchor.z).angle() + (PI * 1.5)
	area3d.rotation.x = -Vector2(old_anchor.y, old_anchor.z).angle() + (PI * 1.5)

## Called in-editor when changes are made to the tightrope. Updates mesh and colliders.
## Ropes should not be changed during runtime.
func update_length() -> void:
	if mesh == null:
		return
	
	mesh.position = (old_anchor) * 0.5
	mesh.mesh.height = (old_anchor * Vector3(1,0,1)).length()
	
	collision_shape.shape.height = (old_anchor * Vector3(1,0,1)).length()
#endregion

#region Catenary Curve calculations
## This function calculates the catenary curve and applies it to the mesh's shader parameters.
func calculate_catenary_offsets() -> void:
	var x1 : float = 0
	var y1 : float = 0
	var x2 : float = ((anchor.position) * Vector3(1,0,1)).length()
	var y2 : float = anchor.position.y
	
	var f : Dictionary = solve_catenary(x1, y1, x2, y2)
	
	mesh.set_instance_shader_parameter("a", f["a"])
	mesh.set_instance_shader_parameter("x0", f["x0"])
	mesh.set_instance_shader_parameter("y0", f["y0"] - y2/2)
	mesh.set_instance_shader_parameter("x1", x1)
	mesh.set_instance_shader_parameter("x2", x2)

func solve_catenary(x1 : float, y1 : float, x2 : float, y2 : float) -> Dictionary:
	if x1 > x2:
		var tx := x1
		var ty := y1
		x1 = x2
		y1 = y2
		x2 = tx
		y2 = ty
	
	var h : float = x2 - x1
	var v : float = y2 - y1
	var d : float = sqrt(h*h + v*v) * 1.03
	
	var target : float = sqrt(d*d - v*v)
	var lambda = func f(_a):
		return 2*_a*sinh(h/(2*_a)) - target
	
	var a_lo : float = 0.000001 * h
	var a_hi : float = h
	while lambda.call(a_hi) > 0:
		a_hi = a_hi*2
	
	for i in 100:
		var a_mid : float = 0.5 * (a_lo + a_hi)
		if lambda.call(a_mid) > 0:
			a_lo = a_mid
		else:
			a_hi = a_mid
	
	var a : float = 0.5 * (a_lo + a_hi)
	
	var x0 : float = 0.5*(x1 + x2) - a * atanh(v/d)
	var y0 : float = y1 - a * cosh((x1 - x0) / a)
	
	return {"a" : a, "x0" : x0, "y0" : y0}
#endregion
