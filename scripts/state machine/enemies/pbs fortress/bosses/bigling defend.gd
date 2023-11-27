extends Node

var state_name = "Defend"

@onready var state = get_parent()
@onready var body = get_parent().get_parent()
@onready var punyling =  get_parent().get_parent().get_parent().find_child("Punyling")

var timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	state.state_dictionary[state_name] = self

func update(delta):
	
	#process gravity
	state.velocity.y += -9.8 * delta
	
	var distance_to_punyling = (punyling.global_position - body.global_position).length()
	var punyling_distance_toplayer = (punyling.global_position - state.player.global_position).length()
	var distance_toplayer = (body.global_position-state.player.global_position).length()
	var direction
	if distance_to_punyling < punyling_distance_toplayer:
		direction = distance_to_line() + body.global_position.direction_to(state.player.global_position)
		if distance_toplayer > 30 and distance_toplayer < 50 and timer.time_left == 0:
			state.update_state("Rush")
			return
	else:
		direction = body.global_position.direction_to(state.player.global_position)
		if distance_toplayer < 20 and timer.time_left == 0:
			state.update_state("Rush")
			return
	
	direction = direction.normalized()
	
	state.current_direction = state.current_direction.slerp(direction, .015)
	state.current_speed = lerp(state.current_speed, state.max_speed, .15)
	
	pass

func reset():
	timer.start(5)
	get_node("../../CSGBox3D").material.albedo_color = Color.BLUE

func distance_to_line() -> Vector3:
	var p0 = body.global_position
	var p1 = punyling.global_position
	var p2 = state.player.global_position
	
	var top_half = (p2.x - p1.x) * (p1.y - p0.y) - (p1.x - p0.x) * (p2.y - p1.y)
	top_half = abs(top_half)
	
	var bottom_half = pow((p2.x-p1.x),2) + pow((p2.y - p1.y),2)
	bottom_half = sqrt(bottom_half)
	
	var distance = top_half/bottom_half
	
	var vector = (p2-p1).cross(Vector3.UP).normalized()
	vector = (p1-p0).project(vector)
	return vector*distance
