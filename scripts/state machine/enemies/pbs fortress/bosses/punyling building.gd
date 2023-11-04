extends Node

var state_name = "Building"

@onready var state = get_parent()
@onready var body = get_parent().get_parent()
@onready var rubbish_ball = $"../../HoldableObjectNode"
var timer
# Called when the node enters the scene tree for the first time.

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	state.state_dictionary[state_name] = self
	timer.connect("timeout", finished_building)

func update(delta):
	state.velocity.y += -9.8 * delta
	pass

func reset():
	timer.start(5)
	state.current_speed = 0
	state.current_direction = Vector3.ZERO
	get_node("../../CSGBox3D").material.albedo_color = Color.CHARTREUSE

func finished_building():
	
	if state._current_state.state_name != state_name:
		return
	
	state.target.visible = false
	state.update_state("Idle")
	if rubbish_ball.current_object == null:
		rubbish_ball.hold_object(load("res://scenes/enemies/pbs fortress/bosses/rubbish ball.tscn").instantiate())
	else:
		rubbish_ball.current_object.increase_size()
