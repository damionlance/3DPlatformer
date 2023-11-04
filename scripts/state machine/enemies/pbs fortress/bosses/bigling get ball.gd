extends Node

var state_name = "Get Ball"

@onready var state = get_parent()
@onready var body = get_parent().get_parent()
@onready var punyling =  get_parent().get_parent().get_parent().find_child("Punyling")
# Called when the node enters the scene tree for the first time.

func _ready():
	state.state_dictionary[state_name] = self

func update(delta):
	
	#process gravity
	
	state.velocity.y += -9.8 * delta
	var direction = punyling.global_position - body.global_position
	
	state.current_direction = state.current_direction.slerp(direction.normalized(), .15)
	state.current_speed = state.max_speed
	pass

func reset():
	state.current_speed = 0
	state.velocity = Vector3.ZERO
	get_node("../../CSGBox3D").material.albedo_color = Color.ANTIQUE_WHITE
