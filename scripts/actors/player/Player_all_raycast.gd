extends Node3D

var velocity := Vector3.ZERO
var previous_velocity := Vector3.ZERO
var horizontal_velocity := Vector3.ZERO
@onready var facing_direction := Vector3(sin(rotation.y), 0, cos(rotation.y))
var delta_v := Vector3.ZERO

var look_at_velocity := true


@onready var raycasts := $"RaycastHandler"
@onready var controller := $"Controller"
@onready var player_model := $"possible final fella"
@onready var collision_drum := $"CollisionDrum"
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
	previous_velocity = velocity
	velocity += delta_v * delta
	var temp = velocity.y
	if raycasts.is_on_floor:
		velocity *= friction
	horizontal_velocity = velocity
	horizontal_velocity.y = 0
	velocity.y = temp
	for normal in raycasts.normals:
		var push_back = velocity.dot(normal)
		var scaled_normal = normal * push_back
		if push_back < 0:
			velocity = velocity - (normal * push_back)
	if velocity.y < -25: velocity.y = -25
	if raycasts.average_floor_distance.y > 0:
		global_position.y += raycasts.average_floor_distance.y
	
	look_forward()
	lean_into_turns()
	global_position += velocity

func align_to_floor():
	look_at(raycasts.average_floor_normal, Vector3.UP, false)

func look_forward():
	var normalized_direction = facing_direction.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = lookdir
	if look_at_velocity and velocity != Vector3.ZERO:
		player_model.rotation.y = 0.0
		facing_direction = velocity.normalized()
	else:
		
		player_model.rotation.y = - rotation.y

func lean_into_turns():
	var direction
	var lateralAxis = velocity.normalized().cross(Vector3.UP).normalized()
	if delta_v == Vector3.ZERO or raycasts.is_on_wall or not raycasts.is_on_floor:
		direction = Vector3.ZERO
	else:
		direction = controller.camera_relative_movement
	direction = -(direction.dot(lateralAxis)) * .7
	player_model.rotation.z = lerp(player_model.rotation.z, -direction, .15)

