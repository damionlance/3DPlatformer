extends Enemy

@export var max_wander_turn_angle : float = 0.0174533
@export var max_wander_walk_speed : float = 5.0
@export var max_wander_time : float = 3.0

@onready var wander_timer := $"%Wander Timer"
@onready var left_raycast := $"%Left Side Raycast"
@onready var right_raycast := $"%Right Side Raycast"
@onready var navigation_agent := $"%NavigationAgent3D"
@onready var body := $"%Body"

var delta_v := Vector3.ZERO

var _wander_turn_angle : float = 0.0
var _wander_walk_speed : float = 0.0

var wander_speed_tween : Tween
var wander_angle_tween : Tween

var _pathfinding_target_location := Vector3(-1000, -1000, -1000)

func _ready() -> void:
	if get_parent() is EnemySpawnZone:
		spawn_zone = get_parent()
	movement_direction = movement_direction.rotated(Vector3.UP, rotation.y)
	floor_alignment_raycast = $"%Floor Alignment Raycast"
	state_chart = $%StateChart


func _physics_process(delta: float) -> void:
	velocity += delta_v * delta
	
	move_and_slide()
	delta_v = Vector3.ZERO

func idle(delta: float) -> void:
	await get_tree().create_timer(randf_range(3, 10)).timeout
	state_chart.send_event("wander")

func start_wander() -> void:
	_wander_turn_angle = randf_range(-max_wander_turn_angle, max_wander_turn_angle)
	_wander_walk_speed = randf_range(.1, max_wander_walk_speed)
	wander_timer.start(randf_range(.1, max_wander_time))

func reset_velocity() -> void:
	velocity = Vector3.ZERO

func stop_wander() -> void:
	wander_timer.stop()

func wander_timer_timeout() -> void:
	state_chart.send_event("idle")

func look_forward(delta: float) -> void:
	if movement_direction == Vector3.ZERO:
		return
	var normalized_direction = movement_direction.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = lerp(rotation.y, lookdir, .15)

func wander(delta: float) -> void:
	var left_raycast_collision = left_raycast.is_colliding()
	var right_raycast_collision = right_raycast.is_colliding()
	
	var adjusted_wander_angle = _wander_turn_angle
	
	if not left_raycast_collision and not right_raycast_collision:
		movement_direction = movement_direction.rotated(Vector3.UP, PI)
	elif not left_raycast_collision:
		adjusted_wander_angle = -max_wander_turn_angle * 3
	elif not right_raycast_collision:
		adjusted_wander_angle = max_wander_turn_angle * 3
	
	delta_v = movement_direction
	delta_v = delta_v.rotated(Vector3.UP, adjusted_wander_angle)
	movement_direction = delta_v
	
	delta_v.y = -90
	delta_v *= _wander_walk_speed

func align_to_floor(_delta) -> void:
	var floor_normal = floor_alignment_raycast.get_collision_normal()
	if floor_normal == Vector3.ZERO:
		return
	var xform = global_transform
	var new_y = floor_normal
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	if body != null:
		body.global_transform = body.global_transform.interpolate_with(xform, 0.1)

func hazard_reaction(body : Node) -> void:
	if body == self:
		return
	queue_free()

func pursue_player(delta : float) -> void:
	if (player.global_position - global_position).length() < enemy_detection_range:
		if (player.global_position - _pathfinding_target_location).length() > 1.0:
			_pathfinding_target_location = player.global_position
			navigation_agent.set_target_position(_pathfinding_target_location)
		movement_direction = (navigation_agent.get_next_path_position() - global_position)
		movement_direction.y = 0
		movement_direction = movement_direction.normalized()
		
		delta_v = movement_direction * max_speed
		delta_v.y = -90
	else:
		state_chart.send_event("idle")
