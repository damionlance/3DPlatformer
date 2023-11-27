extends Node

#private variables
var state_name = "Tossing"
#onready variables
@onready var state = get_parent()
@onready var _friendo = get_parent().get_parent()
@onready var _popper = $"../../PopperBounceArea"
@onready var _camera = $"../../../../CameraPivot"

var aim_direction = Vector3.ZERO

var popperTimer := 0
var popperBuffer := 120

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(_delta):
	var forwards = _camera.global_transform.basis.z
	forwards.y = 0
	forwards = forwards.normalized()
	forwards *= state.controller.movement_direction.y
	var right = _camera.global_transform.basis.x * state.controller.movement_direction.x
	var camera_relative_movement = -forwards + -right
	aim_direction = Vector3(camera_relative_movement.x, 1, camera_relative_movement.z)
	for body in _popper.get_overlapping_bodies():
		if body is CharacterBody3D:
			if not body.get("popperBounce") == null:
				if not body.popperBounce:
					body.popperBounce = true
					body.popperAngle = aim_direction
					popperTimer = 0
	
	# State processing
	if popperTimer != popperBuffer:
		popperTimer += 1
	else:
		popperTimer = 0
		state.update_state("Idle")
	# handle all movement processing
	pass

func reset():
	popperTimer = 0
	aim_direction = Vector3(state.controller.movement_direction.x, 1, state.controller.movement_direction.y)
	state.move_direction = Vector3.ZERO
	state.movement_speed = 0
	pass
