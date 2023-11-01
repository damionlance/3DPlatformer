extends Node

var state_name = "Rush"

@onready var state = get_parent()
@onready var body = get_parent().get_parent()
@export var dash_speed = 40.0

var previous_velocity := Vector3.ZERO
var direction = Vector3.ZERO
# Called when the node enters the scene tree for the first time.

func _ready():
	state.state_dictionary[state_name] = self

func update(delta):
	if direction == Vector3.ZERO:
		return
	#process gravity
	state.velocity.y += -9.8 * delta
	var test_velocity = Vector3(body.velocity.x, 0, body.velocity.z)
	if test_velocity.length() > previous_velocity.length():
		previous_velocity = test_velocity
	state.current_speed = lerp(state.current_speed, dash_speed, .05)
	if body.is_on_wall():
		for i in body.get_slide_collision_count():
			if body.get_slide_collision(i).get_collider().name == "Player":
				state.player.find_child("StateMachine", false).velocity = previous_velocity * 2
				state.player.find_child("StateMachine", false).update_state("Slammed")
		state.update_state("Stun")
	pass

func reset():
	previous_velocity = Vector3.ZERO
	direction = Vector3.ZERO
	state.current_speed = 0
	state.velocity = Vector3.ZERO
	var tween = create_tween()
	get_node("../../CSGBox3D").material.albedo_color = Color.YELLOW
	tween.tween_property(body, "rotation:y", body.rotation.y+.35, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(body, "rotation:y", body.rotation.y-.35, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(body, "rotation:y", body.rotation.y, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	get_node("../../CSGBox3D").material.albedo_color = Color.CRIMSON
	direction = state.player.global_position - body.global_position
	direction.y = 0
	direction = direction.normalized()
	state.current_direction = direction
	
