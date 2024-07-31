class_name NPC extends CharacterBody3D

@export var dialogue : DialogueResource = null

var delta_v := Vector3.ZERO
@onready var state_chart = $"StateChart"

func _ready() -> void:
	if dialogue != null:
		$"Dialogue Detection Zone".dialogue = dialogue

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= 100 * delta
	
	velocity += delta_v * delta
	delta_v = Vector3.ZERO
	move_and_slide()

func look_forward(_delta: float) -> void:
	if velocity == Vector3.ZERO:
		return
	var normalized_direction = velocity.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = lerp(rotation.y, lookdir, 1)

func enable_dialogue(enabled : bool, body : Player = null) -> void:
	if enabled == false:
		state_chart.send_event("Idle")
		return
	if body == null:
		state_chart.send_event("Idle")
		return
	
	velocity = body.global_position - global_position
	velocity.y = 0
	look_forward(0.0166)
	velocity = Vector3.ZERO
	state_chart.send_event("in dialogue")
