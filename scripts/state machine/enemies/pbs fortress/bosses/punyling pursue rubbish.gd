extends Node

var state_name = "Pursue Rubbish"

@onready var state = get_parent()
@onready var body = get_parent().get_parent()
@onready var bigling = weakref(get_parent().get_parent().get_parent().find_child("Bigling"))
# Called when the node enters the scene tree for the first time.

var timer

func _ready():
	state.state_dictionary[state_name] = self

func update(delta):
	#process gravity
	state.velocity.y += -9.8 * delta
	if not bigling.get_ref():
		body.queue_free()
		return
	if state.target.visible == true:
		var avoid_bigling_direction = Vector3.ZERO
		if $"../../RayCast3D".is_colliding():
			avoid_bigling_direction = $"../../RayCast3D".get_collision_normal()
		if is_rubbish_past_enemies():
			var pos_difference = (find_spot_behind_bigling() - body.global_position + avoid_bigling_direction).normalized()
			state.current_direction = state.current_direction.slerp(pos_difference, .15)
			state.current_speed = lerp(state.current_speed, state.max_speed, .15)
		else:
			var bigling_dist = bigling.get_ref().global_position - state.target.global_position
			var punyling_dist = body.global_position - state.target.global_position
			var bigling_in_way = Vector3.FORWARD*500.0
			if bigling_dist.length() < punyling_dist.length():
				bigling_in_way = distance_to_line()
			var pos_difference = state.target.global_position - body.global_position
			if pos_difference.length() <= 3:
				state.update_state("Building")
				return
			else:
				var new_dir = pos_difference.normalized() + avoid_bigling_direction + Vector3.ZERO if bigling_in_way.length() > 5.0 else bigling_in_way.normalized() * 2.5
				state.current_direction = state.current_direction.slerp(new_dir, .15)
				state.current_speed = lerp(state.current_speed, state.max_speed, .15)
	
	pass

func reset():
	state.current_speed = 0
	state.current_direction = Vector3.ZERO
	get_node("../../CSGBox3D").material.albedo_color = Color.CHOCOLATE

func distance_to_line() -> Vector3:
	var p0 = bigling.get_ref().global_position
	var p1 = body.global_position
	var p2 = state.target.global_position
	
	var top_half = (p2.x - p1.x) * (p1.y - p0.y) - (p1.x - p0.x) * (p2.y - p1.y)
	top_half = abs(top_half)
	
	var bottom_half = pow((p2.x-p1.x),2) + pow((p2.y - p1.y),2)
	bottom_half = sqrt(bottom_half)
	
	var distance = top_half/bottom_half
	
	var vector = (p2-p1).cross(Vector3.UP).normalized()
	vector = (p1-p0).project(vector)
	return vector*distance

func is_rubbish_past_enemies():
	var rubbish2d = Vector2(state.target.global_position.x, state.target.global_position.z)
	var punyling2d = Vector2(body.global_position.x, body.global_position.z)
	var player2d = Vector2(state.player.global_position.x, state.player.global_position.z)
	var bigling2d = Vector2(bigling.get_ref().global_position.x, bigling.get_ref().global_position.z)
	if Geometry2D.segment_intersects_segment(player2d, bigling2d, rubbish2d, punyling2d) != null:
		return true
	return false

func find_spot_behind_bigling():
	var direction = (bigling.get_ref().global_position - state.player.global_position).normalized()
	return bigling.get_ref().global_position + (direction * 15)
