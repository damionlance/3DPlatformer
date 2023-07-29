extends CharacterBody3D

@export var camera_sensitivity := Vector2(0,0)
@onready var _player := get_parent()
@onready var _player_state := $"../StateMachine"
@onready var _camera := $"SpringArm3D/Camera3D"

@export var change_in_fov = 7.5
@export var base_fov = 80.0

var previous_camera_height = 0
var camera_tracking_position = Vector3.ZERO

var chase_cam = true

var halt_input := false

var match_height
var tracking = false

var target_body

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	pass # Replace with function body.

func _physics_process(_delta):
	
	var space_state = get_world_3d().direct_space_state
	
	var horizontal_speed = Vector3(_player.velocity.x, 0, _player.velocity.z).length()
	if horizontal_speed > 6:
		_camera.fov = lerp(_camera.fov, base_fov + (change_in_fov * (horizontal_speed/12)), .05)
	else:
		_camera.fov = lerp(_camera.fov, base_fov, .05)
	var _parent_position = _player.global_position + Vector3.UP * 2
	
	var height_difference = previous_camera_height - _parent_position.y
	var camera_horizontal_distance = Vector3(camera_tracking_position.x, 0, camera_tracking_position.z)
	camera_horizontal_distance -= Vector3(_parent_position.x, 0, _parent_position.z)
	
	if Input.is_action_just_pressed("Camera Mode"): chase_cam = bool(1 - int(chase_cam))
	
	if chase_cam:
		if camera_horizontal_distance.length() != 0:
			var p1 = camera_tracking_position - _camera.global_position
			var p2 = _parent_position - _camera.global_position
			var angle = atan2(p1.x, p1.z) - atan2(p2.x, p2.z)
			
			rotation_degrees.y -= rad_to_deg(angle)
	
	if not halt_input:
		rotation_degrees.x -= Input.get_axis("CameraDown", "CameraUp") * camera_sensitivity.x
		rotation_degrees.x = clamp(rotation_degrees.x, -80.0, 30.0)
		rotation_degrees.y -= Input.get_axis("CameraRight", "CameraLeft") * camera_sensitivity.y
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
		camera_tracking_position = _parent_position
		camera_tracking_position.y = previous_camera_height
		var camera_velocity = lerp(velocity, get_parent().velocity, .9)
		camera_velocity += (_parent_position - global_position)*10
		var match_states = false
		if _player_state._current_state != null:
			match_states = (	_player_state._current_state._state_name == "WallSlide" or 
							_player_state._current_state._state_name == "WallClimb" or
							_player_state._current_state._state_name == "LedgeGrab" or
							_player_state._current_state._state_name == "Running")
		if abs(height_difference) > 6 and not tracking:
			tracking = true
		elif match_states or _player.is_on_floor():
			if match_height:
				var query = PhysicsRayQueryParameters3D.create(_parent_position, position)
				var result = space_state.intersect_ray(query)
				if result:
					position = _parent_position
			match_height = true
			tracking = false
			previous_camera_height = position.y
		else:
			match_height = tracking
		if not match_height:
			if is_on_wall():
				camera_velocity.y = 10
			else:
				camera_velocity.y = 0
		else:
			previous_camera_height = position.y
		
		
		set_velocity(camera_velocity)
		move_and_slide()
	
	#position = camera_tracking_position
	
	pass

func set_target_body(body):
	target_body = body
