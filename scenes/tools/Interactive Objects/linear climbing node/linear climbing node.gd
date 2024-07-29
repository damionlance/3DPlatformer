class_name LinearClimbingNode extends Node3D

var player_original_parent : Node = null
var player : Player = null
@export var climbing_speed : float = 3.0

@export var player_root_motion : bool = false
var height : float
var up_direction := Vector3.ZERO

@onready var attach_node := $"%Attach Point"

signal attached
signal detached

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		return
	
	process_climb(delta)
	process_rotation()
	if Input.is_action_just_pressed("Jump"):
		player.movement_direction = (player.global_position - global_position).normalized()
		player.state_chart.send_event("Jump")
		release_player()
		return
	if player.is_on_floor():
		player.state_chart.send_event("Idle")
		release_player()
		return

func attach_player(body : Node3D, new_position : Vector3) -> void:
	if body.is_on_floor():
		return
	emit_signal("attached")
	
	player_original_parent = body.get_parent()
	player = body
	position = new_position
	look_at(player.global_position, up_direction)
	rotate_object_local(Vector3.UP, PI)
	player.state_chart.send_event("Stationary Interactive State")
	player.state_chart.send_event("Rope Climb")

func process_rotation() -> void:
	rotate_object_local(Vector3.UP, deg_to_rad(Input.get_axis("Left", "Right")))

func process_climb(delta : float) -> void:
	if Input.is_action_pressed("DiveButton"):
		position -= up_direction * climbing_speed * 3 * delta
	if player_root_motion:
		var player_root_motion = player.get_root_motion()
		position += up_direction * player_root_motion.y
	else:
		position += up_direction * Input.get_axis("Backward", "Forward") * climbing_speed * delta
	
	if position.length() < 2:
		position = -up_direction * 2
	if position.length() < -height:
		player.state_chart.send_event("Fall")
		release_player()
		return
	
	player.global_transform = attach_node.global_transform

func release_player() -> void:
	player = null
	player_original_parent = null
	emit_signal("detached")
