extends Node3D

var velocity := Vector3.ZERO
var previous_velocity := Vector3.ZERO
var horizontal_velocity := Vector3.ZERO
var max_horizontal_velocity := 15.0

@onready var facing_direction := Vector3(sin(rotation.y), 0, cos(rotation.y))
@onready var state := $"StateMachine"
var delta_v := Vector3.ZERO

var snap_vector := Vector3.ZERO

var look_at_velocity := true

@onready var raycasts := $"RaycastHandler"
@onready var controller := $"Controller"
@onready var player_model := $"possible final fella"

var state_name := ""
var previous_state_name := ""
var is_on_floor := true
var friction_timer := 0
var friction_buffer := 5
var sideways_friction := 10
var forwards_friction := 10

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state_name = state.current_state.name
	previous_state_name = state.previous_state.name
	is_on_floor = raycasts.is_on_floor
	
	previous_velocity = velocity
	if is_on_floor:
		velocity = apply_friction(delta)
	velocity += delta_v * delta
	for normal in raycasts.normals:
		var push_back = velocity.dot(normal)
		var scaled_normal = normal * push_back
		if push_back < 0:
			velocity = velocity - scaled_normal
	
	
	horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	if raycasts.center_floor_distance > 0:
		global_position.y = raycasts.center_floor_distance + global_position.y
	elif raycasts.closest_floor_distance > 0:
		global_position.y = raycasts.closest_floor_distance + global_position.y
	if raycasts.closest_wall_collision.length() < .5:
		global_position -= raycasts.closest_wall_collision.normalized() * (.5 - raycasts.closest_wall_collision.length())
	
	if velocity.y < -0.8:
		velocity.y = -0.8
	
	align_to_floor()
	look_forward()
	global_position += velocity
	delta_v = Vector3.ZERO
	
	if snap_vector != Vector3.ZERO:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_position - snap_vector, global_position + snap_vector)
		var result = space_state.intersect_ray(query)
		if result and result.position.y < global_position.y:
			global_position = result.position

func apply_friction(delta):
	var forward_velocity = controller.camera_relative_movement
	forward_velocity *= controller.camera_relative_movement.dot(velocity)
	var lateral_velocity = velocity - forward_velocity
	
	lateral_velocity = lerp(lateral_velocity, Vector3.ZERO, sideways_friction * delta) 
	
	if forward_velocity.length() > max_horizontal_velocity * delta:
		forward_velocity = lerp(forward_velocity, Vector3.ZERO, forwards_friction * delta) 
	
	return forward_velocity + lateral_velocity

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
	if look_at_velocity and controller.camera_relative_movement != Vector3.ZERO:
		player_model.rotation.y = 0.0
		facing_direction = controller.camera_relative_movement.normalized()
	elif not look_at_velocity:
		player_model.rotation.y = - rotation.y

func lean_into_turns():
	var direction
	var lateralAxis = velocity.normalized().cross(Vector3.UP).normalized()
	if delta_v == Vector3.ZERO or raycasts.is_on_wall or not raycasts.is_on_floor:
		direction = Vector3.ZERO
	else:
		direction = controller.camera_relative_movement
	direction = -(direction.dot(lateralAxis)) * 1.0


