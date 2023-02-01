extends RayCast


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var colliding := false
var collision_point = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	colliding = is_colliding()
	
	if colliding and collision_point == Vector3.ZERO:
		collision_point = get_collision_point()
	elif not colliding:
		collision_point = Vector3.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
