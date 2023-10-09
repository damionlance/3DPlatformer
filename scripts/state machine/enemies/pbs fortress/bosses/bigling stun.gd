extends Node

var state_name = "Stun"

@onready var state = get_parent()
@onready var body = get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
var timer
func _ready():
	state.state_dictionary[state_name] = self

func update(delta):
	if timer.time_left <= 0:
		state.update_state("Idle")
	return

func reset():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.start(4.0)
	state.current_speed = 0
	get_node("../../CSGBox3D").material.albedo_color = Color.CYAN
