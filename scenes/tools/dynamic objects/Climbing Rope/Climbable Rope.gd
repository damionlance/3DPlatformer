@tool
class_name ClimbableRope extends DynamicRope

## Rope attaches relevant CharacterBody3Ds to a hook point that then overtakes controls from the player

@export var climbing_speed := 3.0
@export var climber : LinearClimbingNode = null

var player

func _ready() -> void:
	climber.up_direction = -bottom_point.position.normalized()

func _get_configuration_warnings() -> PackedStringArray:
	var warning_array : Array[String] = []
	if climber == null:
		warning_array.append("Must initialize property 'Climber' with LinearClimbingNode.")
	if mesh_instance == null:
		warning_array.append("Must initialize property 'Mesh Instance' with MeshInstance3D.")
	if bottom_point == null:
		warning_array.append("Must initialize property 'Bottom Point' with Node3D.")
	
	return warning_array

func _process(_delta : float) -> void:
	if Engine.is_editor_hint():
		update_length()

func calculate_closest_point_on_line(incoming_point : Vector3) -> Vector3:
	
	var outgoing_point : Vector3 = Vector3.ZERO
	
	var direction = (bottom_point.position).normalized()
	var direction_to_object = incoming_point
	var distance = direction.dot(direction_to_object)
	
	outgoing_point = distance * direction
	
	return outgoing_point

func attach_player(body: Node3D) -> void:
	
	if climber.player == null:
		var new_point = calculate_closest_point_on_line(body.global_position - global_position)
		climber.attach_player(body, new_point)
