extends Node

class_name AerialMovement

#warning-ignore:unused_private_class_variable
var backwardsLedgeGrab := false
var airdrifting := false

var entering_jump_angle

var constants := preload("res://resources/player/aerial physics constants.tres")

@onready var _player = find_parent("Player")
@onready var _state = find_parent("StateMachine")
@onready var _controller = _player.find_child("Controller")

enum wall_collision {
	noCollision,
	wallSlide,
	ledgeGrab,
	wallClimb
}
# Helper Functions
func wall_collision_check():
	if _state._jump_state == _state.spin_jump or _state._jump_state == _state.bonk:
		return wall_collision.noCollision
	if _state._jump_state == _state.dive or _player.is_on_floor() or _state.consecutive_stationary_wall_jump >= 2:
		return wall_collision.noCollision
	var ledgeGrabHit = false
	var collider = _player.get_last_slide_collision()
	if collider:
		if not collider.get_collider() is StaticBody3D:
			return wall_collision.noCollision
	if _state._raycast_left.is_colliding() or _state._raycast_right.is_colliding():
		var bodies = []
		var collision_normals = []
		if _state._raycast_left.is_colliding():
			bodies.append(_state._raycast_left.get_collider().get_parent())
			collision_normals.append(_state._raycast_left.get_collision_normal())
		if _state._raycast_right.is_colliding():
			bodies.append(_state._raycast_right.get_collider().get_parent())
			collision_normals.append(_state._raycast_right.get_collision_normal())
		if bodies[0].is_in_group("climbable zone") or (bodies.size() == 2 and bodies[0].is_in_group("climbable zone") and bodies[1].is_in_group("climbable zone")):
			for normal in collision_normals:
				if (_state._raycast_middle.get_collision_normal() - normal).length() <= .1:
					return wall_collision.wallClimb
		if abs(_state._raycast_left.get_collision_normal().y) <= .1 or abs(_state._raycast_right.get_collision_normal().y) <= .1:
			if (_state._raycast_middle.is_colliding()) and _player.velocity.y < 0:
				var prev_horizontal_speed = _player.previous_horizontal_velocity.length()
				if prev_horizontal_speed > 2 and not _player.grappling:
					return wall_collision.wallSlide
	else:
		if _state._raycast_middle.is_colliding() and _state.velocity.y < 0:
			ledgeGrabHit = true
		_state._raycast_middle.target_position *= -1
		_state._raycast_middle.force_raycast_update()
		if _state._raycast_middle.is_colliding() and _state.velocity.y < 0:
			ledgeGrabHit = true
		_state._raycast_middle.target_position *= -1
		_state._raycast_middle.force_raycast_update()
	
	var wallHit = false
	
	if ledgeGrabHit:
		_state._raycast_left.target_position *= -1
		_state._raycast_left.force_raycast_update()
		_state._raycast_right.target_position *= -1
		_state._raycast_right.force_raycast_update()
		if _state._raycast_left.is_colliding() or _state._raycast_right.is_colliding():
			wallHit = true
		_state._raycast_left.target_position *= -1
		_state._raycast_right.target_position *= -1
	
	if ledgeGrabHit and not wallHit: return wall_collision.ledgeGrab
	return wall_collision.noCollision

func standard_aerial_drift():
	var relative_angle = entering_jump_angle.dot(_state.camera_relative_movement)
	_state.move_direction = lerp(_state.move_direction, _state.camera_relative_movement, .03)
	if _controller.movement_direction == Vector2.ZERO:
		_state.current_speed *= constants.air_friction * .98
	elif relative_angle < -.5:
		_state.current_speed *= constants.air_friction
	elif relative_angle > -.5 and not airdrifting:
		if _state.current_speed < 12:
			_state.current_speed += 3
		airdrifting = true
	if _player.is_on_wall_only():
		var wall_normal = _player.get_last_slide_collision().get_normal()
		var cross = wall_normal.cross(Vector3.UP)
		_state.move_direction = _state.move_direction.project(cross)
	pass

func spin_jump_drift():
	if _state._controller.input_strength < .2:
		_state._air_drift_state = _state.not_air_drifting
		_state.current_speed *= constants.air_friction
	
	_state.move_direction = _state.camera_relative_movement
	if _state.move_direction != Vector3.ZERO:
		if _state.current_speed < 5.0:
			_state.current_speed = lerp(float(_state.current_speed), 5.0, .15)
	
	if _player.is_on_wall():
		var position = _player.get_last_slide_collision().get_position() - _player.global_position
		_state.move_direction = (_state.move_direction - (position.normalized() * constants.spin_skip_strength)).normalized()
	
	pass


func lean_into_walls(wall_normal):
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + -wall_normal, Vector3.UP)
