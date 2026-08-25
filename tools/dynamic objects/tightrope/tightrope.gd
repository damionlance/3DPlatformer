@tool
class_name TightRope extends Node3D

@export var test_cat : bool = false :
	set(value):
		test_cat = value
		if Engine.is_editor_hint():
			test_cat = false

@export var tightrope_mesh : MeshInstance3D
@export var anchor1 : Node3D
@export var anchor2 : Node3D

var old_anchor1 : Vector3 = Vector3.ZERO
var old_anchor2 : Vector3 = Vector3.ZERO

var previous_bottom_point_position : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	calculate_catenary_offsets()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if old_anchor1 != anchor1.position :
			old_anchor1 = anchor1.position
			calculate_catenary_offsets()
			update_length()
	pass

func calculate_catenary_offsets() -> void:
	var x1 : float = 0
	var y1 : float = 0
	var x2 : float = ((anchor1.position) * Vector3(1,0,1)).length()
	var y2 : float = anchor1.position.y
	
	var f : Dictionary = solve_catenary(x1, y1, x2, y2)
	
	tightrope_mesh.set_instance_shader_parameter("a", f["a"])
	tightrope_mesh.set_instance_shader_parameter("x0", f["x0"])
	tightrope_mesh.set_instance_shader_parameter("y0", f["y0"] - y2/2)
	tightrope_mesh.set_instance_shader_parameter("x1", x1)
	tightrope_mesh.set_instance_shader_parameter("x2", x2)

func update_length() -> void:
	if tightrope_mesh == null:
		return
	
	
	tightrope_mesh.position = (old_anchor1) * 0.5
	tightrope_mesh.mesh.height = (old_anchor1 * Vector3(1,0,1)).length()
	
	previous_bottom_point_position = old_anchor1
	tightrope_mesh.rotation.y = -Vector2(old_anchor1.x, old_anchor1.z).angle() + (PI * 1.5)

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
	var d : float = sqrt(h*h + v*v) * 1.045
	
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

func catenary_y(x : float , a : float , x0 : float, y0 : float):
	return y0 + a * cosh((x - x0) / a)

func sample_by_arclength(a : float, x0 : float, y0 : float, x1 : float, x2 : float, N : float):
	var s1 : float = a * sinh((x1 - x0) / a)
	var s2 : float = a * sinh((x2 - x0) / a)
	
	var points : Array = []
	
	for i in N:
		var s : float = s1 + (s2 - s1) * i / N
		var x : float = x0 + a * asinh(s / a)
		points.append(catenary_y(x, a, x0, y0))
