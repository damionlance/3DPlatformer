extends Node
class_name FriendoThrowOut

#private variables
var _state_name = "ThrowOut"
#onready variables
onready var _state = get_parent()
onready var _friendo = get_parent().get_parent()
onready var _grapple_raycast = $"../../../../GrappleRaycast"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.
var gravity
var distanceOfThrow

func update(delta):
	_grapple_raycast.cast_to = _grapple_raycast.to_local(_friendo.global_transform.origin)
	
	if _friendo.is_on_wall() or _friendo.is_on_ceiling() or _grapple_raycast.is_colliding():
		if _grapple_raycast.is_colliding():
			_friendo.translation = _grapple_raycast.get_collision_point()
		_state.update_state("StuckToWall")
		_grapple_raycast.enabled
		return
	if _state._controller._dive_state == 1:
		_state.velocity = Vector3.ZERO
		_state.movement_speed = 0
		_friendo.velocity = Vector3.ZERO
		if abs((_friendo.global_translation-_state._player.global_translation).length()) < distanceOfThrow:
			_friendo.global_translation = ((_state._player.global_translation + Vector3(0,.5,0)) - 
									(_state._player.velocity.normalized() * distanceOfThrow))
		if not _state._controller._throw_state:
			_state.update_state("Tossing")
			return
	_state.movement_speed *= .85
	if _state._controller._throw_state:
		gravity.y -= 15
	else:
		gravity.y = 0
	if _state.movement_speed <= .2:
		if not _state._controller._throw_state:
			_state.update_state("Tossing")
			return
		_state.update_state("Idle")
		return
	
	_state.calculate_velocity(gravity, delta)

func reset():
	
	var pVelocity = $"../../../../StateMachine".velocity
	var pGravity = $"../../../../StateMachine/AerialMovement".current_jump_gravity
	var defaultPGravity = $"../../../../StateMachine/AerialMovement"._jump_gravity
	var pDirection = $"../../../../StateMachine".move_direction
	var pDiveSpeed = $"../../../../StateMachine/AerialMovement".dive_speed
	var pJump = $"../../../../StateMachine/AerialMovement"._jump_strength*.5
	
	pVelocity += (pDirection * pDiveSpeed) + Vector3.UP * pJump
	var timeOfJump
	if pGravity != 0:
		 timeOfJump = 2*( pVelocity.y / pGravity)
	else:
		timeOfJump = 2*( pVelocity.y / defaultPGravity)
	pVelocity.y = 0
	distanceOfThrow = (pVelocity.length() * timeOfJump)
	
	gravity = Vector3.ZERO
	if _state._player_state.camera_relative_movement:
		_state.move_direction = _state._player_state.camera_relative_movement
	else:
		_state.move_direction = _state._player_state.current_dir
	_state.movement_speed = 30*_state.max_speed
	_grapple_raycast.enabled = true
	_grapple_raycast.cast_to = Vector3.ZERO
	pass
