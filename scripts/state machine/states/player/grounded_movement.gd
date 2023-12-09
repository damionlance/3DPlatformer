extends Node

class_name GroundedMovement

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Floor Physics Constants
@export var floor_acceleration := 7.0
@export var slide_acceleration := 20.0
const safe_floor_angle := 0.88
var slope_strength := 0.0

var delta_v := Vector3.ZERO

@onready var player = find_parent("Player")
@onready var state = find_parent("StateMachine")
@onready var controller = player.find_child("Controller", false)
@onready var raycasts := player.find_child("RaycastHandler", false)
@onready var animation_tree = player.find_child("AnimationTree")


func _ready():
	
	pass

func grounded_movement_processing(delta) -> Vector3:
	#Reset vertical wall jump tech limit
	delta_v = Vector3.ZERO
	
	delta_v = controller.camera_relative_movement * controller.input_strength * floor_acceleration
	var plane = Plane(raycasts.average_floor_normal)
	var magnitude = delta_v.length()
	delta_v = plane.project(delta_v) * magnitude * delta
	delta_v += calculate_velocity_change_of_slope() * delta
	return delta_v

func calculate_velocity_change_of_slope():
	
	var slope_direction := Plane(raycasts.average_floor_normal).project(Vector3.DOWN).normalized()
	var final_slope_strength := 0.0
	if raycasts.average_floor_normal.y == 1.0:
		slope_strength = 0.0
	if raycasts.average_floor_normal.y > safe_floor_angle: #You are not going to slide down the slope, you'll just slow down
		if controller.camera_relative_movement == Vector3.ZERO:
			slope_strength = 0.0
			return Vector3.ZERO
		var current_grade = 1.0 - raycasts.average_floor_normal.y
		var maximum_grade = 1.0 - safe_floor_angle
		slope_strength = floor_acceleration * (current_grade / maximum_grade)
	
	elif raycasts.average_floor_normal.y > .08 and false: #you're sliding down a slope but not falling
		if player.velocity.dot(slope_direction) >= 0:
			delta_v = Vector3.ZERO
		var current_grade : float = safe_floor_angle - raycasts.average_floor_normal.y
		var maximum_grade := .08
		slope_strength = (current_grade / maximum_grade) * slide_acceleration
	
	return slope_direction * slope_strength
