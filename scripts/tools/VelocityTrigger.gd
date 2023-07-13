extends ShapeCast3D

@export var requiredSpeed := 0.0

signal velocity_trigger_fired(body)

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

func _process(delta):
	for i in get_collision_count():
		var body = get_collider(i)
		if body is CharacterBody3D:
			print(body.velocity.y)
			if body.velocity.y < requiredSpeed:
				emit_signal("velocity_trigger_fired",body)
		if body is RigidBody3D:
			if body.linear_velocity.y < requiredSpeed:
				emit_signal("velocity_trigger_fired", body)
