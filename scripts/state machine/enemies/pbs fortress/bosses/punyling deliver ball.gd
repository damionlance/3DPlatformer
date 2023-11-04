extends Node

var state_name = "Deliver Ball"

@onready var state = get_parent()
@onready var body = get_parent().get_parent()
@onready var rubbish_ball = $"../../HoldableObjectNode"
@onready var bigling = weakref(get_parent().get_parent().get_parent().find_child("Bigling"))
# Called when the node enters the scene tree for the first time.

func _ready():
	state.state_dictionary[state_name] = self

func update(delta):
	#process gravity
	state.velocity.y += -9.8 * delta
	
	if (bigling.get_ref().global_position - body.global_position).length() < 5:
		var ball = rubbish_ball.current_object
		rubbish_ball.drop_object()
		bigling.get_ref().find_child("HoldableObjectNode", false).hold_object(ball)
		bigling.get_ref().find_child("StateMachine", false).update_state("Throw")
		state.update_state("Idle")
	else:
		var direction = bigling.get_ref().global_position - body.global_position
		
		state.current_direction = state.current_direction.slerp(direction.normalized(), .15)
		state.current_speed = state.max_speed
	
	pass

func reset():
	bigling.get_ref().find_child("StateMachine", false).update_state("Get Ball")
	state.current_speed = 0
	get_node("../../CSGBox3D").material.albedo_color = Color.ANTIQUE_WHITE
