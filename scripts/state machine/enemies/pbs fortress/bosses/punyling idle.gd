extends Node

var state_name = "Idle"

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
	var closest_rubbish = null
	
	if rubbish_ball.current_object != null:
		if rubbish_ball.current_object.current_level == 3:
			state.update_state("Deliver Ball")
			return
	for rubbish in get_tree().get_nodes_in_group("rubbish piles"):
		if rubbish.visible == true:
			if closest_rubbish == null:
				closest_rubbish = rubbish
			if (rubbish.global_position - bigling.get_ref().global_position).length() > 8:
				if rubbish.global_position - body.global_position < closest_rubbish.global_position - body.global_position:
					closest_rubbish = rubbish
	if closest_rubbish != null:
		state.target = closest_rubbish
		state.update_state("Pursue Rubbish")
		return
	
	
	pass

func reset():
	state.current_speed = 0
	state.current_direction = Vector3.ZERO
	get_node("../../CSGBox3D").material.albedo_color = Color.ANTIQUE_WHITE
