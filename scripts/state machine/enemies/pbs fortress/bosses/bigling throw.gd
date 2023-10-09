extends Node

var state_name = "Throw"

@onready var state = get_parent()
@onready var body = get_parent().get_parent()
@onready var rubbish_ball = $"../../HoldableObjectNode"
# Called when the node enters the scene tree for the first time.

func _ready():
	state.state_dictionary[state_name] = self

func update(delta):
	
	#process gravity
	state.velocity.y += -9.8 * delta
	var dot = state.current_direction.normalized().dot((state.player.global_position - body.global_position).normalized())
	if dot > .95 and rubbish_ball.current_object != null:
		var direction = state.player.global_position - body.global_position
		var temp_object = rubbish_ball.current_object
		temp_object.linear_velocity = direction * 4
		temp_object.linear_velocity.y += 15
		rubbish_ball.drop_object()
		state.update_state("Idle")
		return
	state.current_direction = state.current_direction.slerp(state.body.global_position.direction_to(state.player.global_position), .015)
	pass

func reset():
	state.current_speed = 0
	state.velocity = Vector3.ZERO
	get_node("../../CSGBox3D").material.albedo_color = Color.ANTIQUE_WHITE
