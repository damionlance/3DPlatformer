extends AerialMovement


#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "WallClimb"
var snapped_to_ledge = false

var height_of_platform := 0
#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	
	
	# Handle state logic
	if _player.is_on_floor():
		_state.update_state("Running")
		return
	if _state.attempting_jump:
		_state._jump_state = _state.jump
		_state.move_direction = _state.camera_relative_movement
		_state.current_speed = 10
		_state.update_state("Jump")
		return
	if (_state._raycast_right.is_colliding() and not _state._raycast_left.get_collider().get_parent().get_parent().is_in_group("climbable zone")
		and _state._raycast_left.is_colliding() and not _state._raycast_right.get_collider().get_parent().get_parent().is_in_group("climbable zone")):
		_state._jump_state = _state.jump
		_state.update_state("Falling")
	# Handle animation tree
	
	# Process movements
	var input = Vector3(_state.camera_relative_movement.x, 0, _state.camera_relative_movement.z)
	var direction = input.signed_angle_to(_state.snap_vector, Vector3.UP)
	
	var wall_vector
	if _state._raycast_middle.get_collision_normal() != Vector3.UP:
		wall_vector = _state._raycast_middle.get_collision_normal()
	elif _state._raycast_right.get_collision_normal() != Vector3.UP:
		wall_vector = _state._raycast_right.get_collision_normal()
	else:
		wall_vector = _state._raycast_left.get_collision_normal()
		
	var wall_sideways = wall_vector.cross(Vector3.UP)
	var wall_up = wall_vector.cross(wall_sideways)
	
	lean_into_walls(wall_vector)
	
	# Update relevant counters
	var dot = _state.camera_relative_movement.dot(_state.snap_vector)
	_state.current_speed = 0
	_state.move_direction = Vector3.ZERO
	
	#Handle Up and Down Movement
	_state.current_speed = 1
	_state.move_direction -= wall_up * _state._controller.movement_direction.y
	_state.move_direction += wall_sideways * _state._controller.movement_direction.x
	
	# Process Physics
	_state.velocity = _state.calculate_velocity(0, delta)
	
	pass

func reset():
	snapped_to_ledge = false
	_state.velocity = Vector3(0, _state.velocity.y, 0)
	_state.move_direction = Vector3.ZERO
	_state.current_speed = 0
	_state.snap_vector = -_state._raycast_middle.get_collision_normal()
	_state.snap_vector.y = 0
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.snap_vector, Vector3.UP)
	if _player.anim_tree != null:
		_player.anim_tree.travel("Run")
		_player.player_anim_tree["parameters/Run/Blend/blend_amount"] = 0
	pass
