extends GroundedMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Running"
var _fall_timer := 0

var vertical_rotation

var base_rotation = 0
var can_slide := false
var can_slide_timer := 0
var can_slide_buffer := 5
var previous_speed := 0
# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass 

func update(delta):
	# Handle all states
	if not _state.restricted_movement:
		if _state._controller.spin_entered:
			_state.update_state("Floor Spin")
			return
		if _state._controller.pivot_entered and can_slide:
			_state.update_state("FloorSlide")
			return
		if _state.attempting_dive:
			if _player.grappling:
				_state.update_state("ReelIn")
			else:
				_state._jump_state = _state.dive
				_state.update_state("Jump")
			return
	if _state.attempting_jump and not _state.can_interact:
		
		if _state.current_speed < 5:
			for body in get_tree().get_nodes_in_group("holdable"):
				if (body.global_position - _player.global_position).length() < 2.5:
					if previous_move_direction.dot((body.global_position - _player.global_position)) > .5:
						_state._holdable_object_node.hold_object(body)
						return
		
		if _state.just_landed and _state.current_jump < 3:
			_state.current_jump += 1
		else:
			_state.current_jump = 1
		_state._jump_state = _state.current_jump
		_state.update_state("Jump")
		return
	if not _player.is_on_floor():
		_fall_timer += 1
		if _fall_timer > _state.coyote_time:
			_state._jump_state = _state.jump
			_state.update_state("Falling")
			return
	else:
		_fall_timer = 0
	# Handle Animation Tree
	if _state.attempting_throw:
		_state._throw()
	
	# Process all inputs
	
	previous_speed = _state.current_speed
	lean_into_turns()
	grounded_movement_processing()
	look_forward()
	var speed_difference = previous_speed - _state.current_speed
	
	if speed_difference < -5:
		_state.anim_tree[_state.is_dashing] = true
		_state.anim_tree[_state.is_stopping] = false
	if speed_difference > 1:
		_state.anim_tree[_state.is_dashing] = false
		_state.anim_tree[_state.is_stopping] = true
	else:
		_state.anim_tree[_state.is_dashing] = false
		_state.anim_tree[_state.is_stopping] = false
	
	if _state.current_speed == 0:
		_state.anim_tree[_state.is_moving] = false
		_state.anim_tree[_state.is_idling] = true
	else:
		_state.anim_tree[_state.is_moving] = true
		_state.anim_tree[_state.is_idling] = false
	
	# Process all relevant timers
	if _state.current_speed > max_speed * .9:
		can_slide = true
		can_slide_timer = 0
	elif can_slide:
		can_slide_timer += 1
		if can_slide_timer == can_slide_buffer:
			can_slide_timer = 0
			can_slide = false

	#Process physics
	_state.velocity = _state.calculate_velocity(0, delta)
	
	pass

func reset():
	_state._reset_animation_parameters()
	
	_state._air_drift_state = _state.not_air_drifting
	var collision = _player.get_last_slide_collision()
	if collision:
		_state.snap_vector = Vector3.DOWN
	else:
		_state.snap_vector = Vector3.ZERO
	_state.velocity.y = 0
	can_slide = false
	can_slide_timer = 0
	_player.rotation.z = 0
	pass
