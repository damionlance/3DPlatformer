extends Node3D

var velocity := Vector3.ZERO
var previous_velocity := Vector3.ZERO
var horizontal_velocity := Vector3.ZERO


@onready var facing_direction := Vector3(sin(rotation.y), 0, cos(rotation.y))
var delta_v := Vector3.ZERO

var snap_vector := Vector3.ZERO

var look_at_velocity := true

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
func _process(delta):
	previous_velocity = velocity
	velocity += delta_v * delta
	if raycasts.is_on_floor: velocity *= friction
	
	
	for normal in raycasts.normals:
		var push_back = velocity.dot(normal)
		var scaled_normal = normal * push_back
		if push_back < 0:
			velocity = velocity - scaled_normal
	
	horizontal_velocity = Vector3(velocity.x, 0, velocity.y)
	if velocity.y < -1: velocity.y = -1
	
	if raycasts.center_floor_distance.y > global_position.y:
		global_position.y = raycasts.center_floor_distance.y
		velocity.y = 0
	if raycasts.closest_wall_collision.length() < .5:
		global_position -= raycasts.closest_wall_collision.normalized() * (.5 - raycasts.closest_wall_collision.length())
	
	align_to_floor()
	look_forward()
	lean_into_turns()
	global_position += velocity
	delta_v = Vector3.ZERO
	
	if snap_vector != Vector3.ZERO:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_position - snap_vector, global_position + snap_vector)
		var result = space_state.intersect_ray(query)
		if result and result.position.y < global_position.y:
			global_position = result.position

func align_to_floor():
	if raycasts.average_floor_normal == Vector3.ZERO:
		return
	var xform = player_model.global_transform
	var new_y = raycasts.average_floor_normal
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	player_model.global_transform = player_model.global_transform.interpolate_with(xform, 0.2)

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


