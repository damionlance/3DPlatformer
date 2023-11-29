extends AnimatableBody3D

var collision_normals := []
@onready var player = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var collision = KinematicCollision3D.new()
	collision_normals = []
	if not test_move(global_transform, player.velocity, collision):
		return
	print(collision.get_collision_count())
	for i in collision.get_collision_count():
		collision_normals.append(collision.get_normal(i))
