class_name LinearMovementConstraint extends RemoteTransform3D

@export var vertical : bool = false
@export var speed : float = 3.0
@export var offset : Vector3

var active : bool = false

var direction : Vector3 = Vector3.ZERO
var anchor_pos : Vector3
var movement_input : Vector3
var player : Player
var type : String

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not active:
		return
	_input_handling()
	var test_pos = position + (movement_input * speed * delta) - offset
	print(test_pos)
	
	if is_equal_approx(test_pos.length() + (anchor_pos - test_pos).length(), anchor_pos.length()):
		position = test_pos + offset

func _input_handling() -> void:
	
	var input : Vector2= Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_vector : Vector3
	if vertical:
		input_vector = Vector3(input.x, -input.y, 0)
	else:
		input_vector = Vector3(input.x, 0, input.y).rotated(Vector3.UP, get_viewport().get_camera_3d().rotation.y)
	movement_input = input_vector.dot(direction) * direction
	if Input.is_action_just_pressed("Jump"):
		_remove_body()

func _attach_body(body: Node3D) -> void:
	active = true
	position = calculate_closest_point_on_line(body.global_position - global_position) + offset
	remote_path = body.get_path()
	player = body
	player.enter_movement_constraint(type)
	snap_player_looking_direction()

func _remove_body() -> void:
	position = offset
	var input : Vector2= Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.velocity += Vector3(input.x, 0, input.y).rotated(Vector3.UP, get_viewport().get_camera_3d().rotation.y) * 5
	remote_path = ""
	player = null
	active = false

func snap_player_looking_direction() -> void:
	if player.facing_direction.dot(direction) < 0:
		player.look_at(direction + player.global_position)
	else:
		player.look_at(-direction + player.global_position)

func calculate_closest_point_on_line(incoming_point : Vector3) -> Vector3:
	var outgoing_point : Vector3 = Vector3.ZERO
	
	var distance = direction.dot(incoming_point)
	
	outgoing_point = distance * direction
	
	return outgoing_point
