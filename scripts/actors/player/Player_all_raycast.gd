extends Node3D

var velocity := Vector3.ZERO
var delta_v := Vector3.ZERO



@onready var raycasts := $"RaycastHandler"
@onready var controller := $"Controller"
@onready var player_model := $"possible final fella"
var friction = .9

var jump_state := 0
enum {
	no_jump,
	jump,
	jump2,
	jump3,
	long_jump,
	spin_jump,
	wall_spin,
	side_flip,
	dive,
	rollout,
	popper_bounce,
	ground_pound,
	quick_getup,
	bonk
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity += delta_v * delta
	var temp = velocity.y
	velocity *= friction
	velocity.y = temp
	if raycasts.vertical_distances[0] + 1 > velocity.y and velocity.y < 0:
		velocity.y = raycasts.vertical_distances[0] + 1
	if raycasts.vertical_distances[0] + 1 > 0 and raycasts.vertical_distances[0] + 1 <= .51:
		global_position.y += raycasts.vertical_distances[0] + 1
	var horizontal_velocity = velocity
	horizontal_velocity.y = 0
	for i in 4:
		if raycasts.horizontal_distances[i].length() - 1 < horizontal_velocity.length():
			var cross = raycasts.horizontal_normals[i].cross(Vector3.UP)
			horizontal_velocity = horizontal_velocity.project(cross)
	horizontal_velocity.y = velocity.y
	velocity = horizontal_velocity
	
	global_position += velocity
	look_forward()
	lean_into_turns()

func look_forward():
	var normalized_direction = velocity.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = lookdir

func lean_into_turns():
	if delta_v == Vector3.ZERO:
		player_model.rotation.z = 0.0
		return
	
	var direction = controller.camera_relative_movement
	var lateralAxis = velocity.normalized().cross(Vector3.UP).normalized()
	direction = -(direction.dot(lateralAxis)) * .5
	player_model.rotation.z = lerp(player_model.rotation.z, -direction, .15)

