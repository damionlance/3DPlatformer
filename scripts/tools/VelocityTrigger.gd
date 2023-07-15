extends ShapeCast3D

@export var requiredSpeed := 0.0
@export var ground_pound := true

signal activate(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(get_parent().mesh, 0)
	var verts = []
	for i in mdt.get_vertex_count():
		verts.append(mdt.get_vertex(i))
	var collisionshape = ConvexPolygonShape3D.new()
	collisionshape.points = PackedVector3Array(verts)
	shape = collisionshape
	position = Vector3.UP

func _process(delta):
	force_shapecast_update()
	for i in get_collision_count():
		if ground_pound:
			_ground_pound_test(get_collider(i))
		else:
			_velocity_test(get_collider(i))

func _ground_pound_test(body):
	if body.name == "Player":
		if body._state._jump_state ==  body._state.ground_pound:
			emit_signal("activate", body)

func _velocity_test(body):
	if body is CharacterBody3D:
		if body.velocity.y < requiredSpeed:
			emit_signal("activate",body)
	if body is RigidBody3D:
		if body.linear_velocity.y < requiredSpeed:
			emit_signal("activate", body)


