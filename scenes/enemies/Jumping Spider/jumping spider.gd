extends CharacterBody3D


@export var dash_speed : float = 50.0
@export var slow_down_speed : float = 100.0
@export var jump_height : float = 5.0
@export var jump_time : float = .5
@export var jump_speed : float = 15.0

@onready var state_chart : StateChart = $"StateChart"
@onready var body := $"%Body"
@onready var floor_alignment_raycast := $"%Floor Alignment Raycast"

var delta_v := Vector3.ZERO
var dash_direction := Vector3.ZERO


var jump_strength = (2 * jump_height) / jump_time
var jump_gravity = (-2.0 * jump_height) / (jump_time * jump_time)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += jump_gravity * delta
	
	
	velocity += delta_v * delta
	delta_v = Vector3.ZERO
	move_and_slide()

func look_forward(_delta: float) -> void:
	if velocity == Vector3.ZERO:
		return
	var normalized_direction = velocity.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = lerp(rotation.y, lookdir, 1)

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

func idle() -> void:
	await get_tree().create_timer(randf_range(3, 10)).timeout
	if randi_range(0,3) == 2:
		state_chart.send_event("jump")
		return 
	state_chart.send_event("dash")

func prep_dash() -> void:
	if Vector3(velocity.x, 0, velocity.z) == Vector3.ZERO:
		velocity = Vector3(randf_range(-1, 1), 0, randf_range(-1,1)).normalized()
	velocity *= dash_speed

func process_dash(delta : float) -> void:
	velocity = velocity.move_toward(Vector3.ZERO, slow_down_speed * delta)
	if velocity == Vector3.ZERO:
		state_chart.send_event("idle")

func prep_jump() -> void:
	if Vector3(velocity.x, 0, velocity.z) == Vector3.ZERO:
		velocity = Vector3(randf_range(-1, 1), 0, randf_range(-1,1)).normalized()
	velocity *= jump_speed
	velocity.y = jump_strength

func check_for_floor(_delta : float) -> void:
	if is_on_floor():
		velocity = Vector3.ZERO
		state_chart.send_event("idle")

func _on_raycasts_stop_moving() -> void:
	if is_on_floor():
		state_chart.send_event("idle")
		velocity = -velocity.normalized()


func hazard_reaction(Hazard: Variant) -> void:
	queue_free()
