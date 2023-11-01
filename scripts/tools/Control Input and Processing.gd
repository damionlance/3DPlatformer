extends Node

var movement_direction := Vector2.ZERO # Always Normalized
var input_strength := 0.0

var previous_direction := Vector2.ZERO

# Spin variables
var angle := [0.0, 0.0]
var turning := 0
var spin_entered := false
var spin_jump_start := Vector2.ZERO
var spin_jump_angle := 0.0
var spin_jump_sign := int(0)

# pivot variables
var pivot_buffer = []

var _jump_state := 0
enum {
	jump_pressed = 1,
	jump_held = 2,
	jump_released = 0
}

var _dive_state := 0
enum {
	dive_pressed = 1,
	dive_held = 2,
	dive_released = 0
}

var _throw_state := 0
enum {
	throw_pressed = 1,
	throw_held = 2,
	throw_released = 0
}

var pivot_entered := false

# Called when the node enters the scene tree for the first time.
func _ready():
	#Input.use_accumulated_input = false
	pivot_buffer.resize(5)
	for i in 5:
		pivot_buffer[i] = Vector2.ZERO
	pass # Replace with function body.

func _process(_delta):
	
	movement_direction = Input.get_vector("Right", "Left", "Backward", "Forward")
	input_strength = movement_direction.length()
	if input_strength > .9:
		input_strength = 1
	
	pivot_buffer.push_front(movement_direction)
	pivot_buffer.pop_back()
	
	if input_strength:
		movement_direction /= input_strength
	
	
	if Input.get_action_strength("Jump"):
		_jump_state = jump_pressed if _jump_state == 0 else jump_held
	else: _jump_state = jump_released
	if Input.get_action_strength("DiveButton"):
		_dive_state = dive_pressed if _dive_state == 0 else dive_held
	else: _dive_state = dive_released
	if Input.get_action_strength("Throw"):
		_throw_state = throw_pressed if _throw_state == 0 else throw_held
	else: _throw_state = throw_released
	
	check_for_spin()
	check_for_pivot()
	pass

var stayed_still_buffer = 5
var stayed_still_timer = 0
var resetplz = false

func check_for_spin():
	if previous_direction == movement_direction or movement_direction == Vector2.ZERO:
		stayed_still_timer += 1
		if stayed_still_buffer == stayed_still_timer:
			resetplz = true
	else: stayed_still_timer = 0
	if spin_entered or resetplz:
		turning = 0
		angle = [0.0, 0.0]
		spin_entered = false
		spin_jump_start = Vector2.ZERO
		spin_jump_angle = 0.0
		spin_jump_sign = 0
		resetplz = false
		stayed_still_timer = 0
	
	elif movement_direction != Vector2.ZERO:
		var lengths = previous_direction.length() * movement_direction.length()
		angle[1] = angle[0]
		
		if lengths:
			angle[0] = movement_direction.angle()
			if angle[0]<0:
				angle[0] += 2*PI
		else:
			angle[0] = angle[1]
		if abs(angle[0]-angle[1]) > .02 and sign(angle[0]-angle[1]) != spin_jump_sign:
			turning = sign(angle[0] - angle[1])
			if spin_jump_sign != -1 and not (angle[1] > deg_to_rad(300) and angle[0] > 0):
				spin_jump_angle = 0
				spin_jump_start = movement_direction
				spin_jump_sign = sign(angle[0]-angle[1])
			if spin_jump_sign != 1 and not (angle[0] > deg_to_rad(300) and angle[1] > 0):
				spin_jump_angle = 0
				spin_jump_start = movement_direction
				spin_jump_sign = sign(angle[0]-angle[1])
		else:
			spin_jump_angle += angle[0] - angle[1]
			if abs(spin_jump_angle) >= deg_to_rad(450):
				spin_entered = true
		previous_direction = movement_direction

func check_for_pivot():
	if pivot_entered:
		pivot_entered = false
		for i in 5:
			pivot_buffer[i] = Vector2.ZERO
		return
	
	var correct_input = null
	var mag = null
	var i = 0
	for _angle in pivot_buffer:
		i += 1
		if i == 1: continue
		if _angle == null:
			pivot_entered = false
			break
		if pivot_buffer[0].dot(_angle) < -.5:
			correct_input = _angle
			break
	
	if correct_input == null:
		return
	var previous_mag
	var previous_angle
	for n in i:
		if previous_angle == pivot_buffer[n]:
			continue
		mag = pivot_buffer[n].length()
		if n != 0:
			if mag == previous_mag:
				break
			if n == i - 1:
				pivot_entered = true
		previous_mag = mag
		previous_angle = pivot_buffer[n]
	pass
