extends Node

var state_name = "Damaged"

@onready var state = get_parent()
@onready var body = get_parent().get_parent()
@onready var rubbish_ball = $"../../HoldableObjectNode"
# Called when the node enters the scene tree for the first time.

func _ready():
	state.state_dictionary[state_name] = self

func update(delta):
	#process gravity
	state.velocity.y += -9.8 * delta
	var closest_rubbish = null
	
	state.update_state("Idle")
	pass

func reset():
	state.current_speed = 0
	if rubbish_ball.current_object != null:
		var player_holdable_object = state.player.find_child("HoldableObjectNode", false)
		if player_holdable_object != null:
			if player_holdable_object.current_object == null:
				var ball = rubbish_ball.current_object
				rubbish_ball.drop_object()
				player_holdable_object.hold_object(ball)
		else:
			rubbish_ball.current_object.destroy()
	get_node("../../CSGBox3D").material.albedo_color = Color.BLACK
