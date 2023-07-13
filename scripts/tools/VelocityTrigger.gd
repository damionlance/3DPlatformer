extends Area3D

@export var requiredSpeed := 0.0

signal velocity_trigger_fired(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	if $CollisionShape3D.shape == null:
		var mdt = MeshDataTool.new()
		mdt.create_from_surface(get_parent().mesh, 0)
		var verts = []
		for i in mdt.get_vertex_count():
			verts.append(mdt.get_vertex(i))
		var collisionshape = ConvexPolygonShape3D.new()
		collisionshape.points = PackedVector3Array(verts)
		$CollisionShape3D.shape = collisionshape

func _on_body_entered(body):
	print(body.velocity.y)
	if body is CharacterBody3D:
		if body.velocity.y < requiredSpeed:
			emit_signal("velocity_trigger_fired",body)
	if body is RigidBody3D:
		if body.linear_velocity.y < requiredSpeed:
			emit_signal("velocity_trigger_fired", body)
