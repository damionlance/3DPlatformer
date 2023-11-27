extends Node

#private variables
var state_name = "ThrowOut"
#onready variables
@onready var state = get_parent()
@onready var _friendo = get_parent().get_parent()
@onready var _grapple_raycast = $"../../../../GrappleRaycast"

var constants := preload("res://resources/player/aerial physics constants.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	
var gravity
var distanceOfThrow

func update(delta):
	_grapple_raycast.target_position = _grapple_raycast.to_local(_friendo.global_transform.origin)
	
	if _friendo.is_on_wall() or _friendo.is_on_ceiling() or _grapple_raycast.is_colliding():
		if _grapple_raycast.is_colliding():
			_friendo.position = _grapple_raycast.get_collision_point()
		state.update_state("StuckToWall")
		_grapple_raycast.enabled = true
		return
	
	if state.controller._divestate == 1:
		state.velocity = Vector3.ZERO
		state.movement_speed = 0
		_friendo.velocity = Vector3.ZERO
		#if abs((_friendo.global_translation-state.player.global_translation).length()) < distanceOfThrow * 2:
		_friendo.global_position = ((state.player.global_position + Vector3(0,.5,0)) - 
									(state.player.velocity.normalized() * distanceOfThrow))
		_friendo.global_position.y = state.player.global_position.y
		state.update_state("Tossing")
		return
	
	state.movement_speed *= .85
	if state.controller.throw_state:
		gravity.y -= 15
	else:
		gravity.y = 0
	if state.movement_speed <= .2:
		if not state.controller.throw_state:
			state.update_state("Tossing")
			return
		state.update_state("Idle")
		return
	
	state.calculate_velocity(gravity, delta)

func reset():
	
	var pVelocity = state.playerstate.velocity
	var pCurrentSpeed = state.playerstate.current_speed
	var pGravity = $"../../../../StateMachine/AerialMovement/Jump".current_jump_gravity
	var defaultPGravity = constants._jump_gravity
	var pMaxSpeed = $"../../../../StateMachine/GroundedMovement".max_speed
	var pDirection = state.playerstate.move_direction
	var pDiveSpeed = 3
	var pJump = $"../../../../StateMachine/AerialMovement/Jump".current_jump_strength*.5
	pVelocity.y = 0
	pVelocity += (pDirection * (pCurrentSpeed + pDiveSpeed)) + Vector3.UP * pJump
	var timeOfJump
	if pGravity != 0:
		timeOfJump = 2*( pVelocity.y / pGravity)
	else:
		timeOfJump = 2*( pVelocity.y / defaultPGravity)
	
	if pCurrentSpeed < pMaxSpeed:
		pVelocity *= pMaxSpeed
	pCurrentSpeed += pDiveSpeed
	distanceOfThrow = (pVelocity.length() * timeOfJump)
	
	gravity = Vector3.ZERO
	if state.playerstate.camera_relative_movement:
		state.move_direction = state.playerstate.camera_relative_movement
	else:
		state.move_direction = state.playerstate.current_dir
	state.movement_speed = 30*state.max_speed
	_grapple_raycast.enabled = true
	_grapple_raycast.target_position = Vector3.ZERO
	pass
