extends AerialMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var state_name = "WallSlide"
var entering_angle : Vector3
var surface_normal : Vector3

var wall_bounce_buffer := 5
var wall_bounce_timer := 0

var forwards
var right

#onready variables
@onready var landing_particles = "res://scenes/particles/landing particles.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(delta):
	wall_bounce_timer += 1
	if player.is_on_floor():
		state.anim_tree["parameters/conditions/wall slide"] = false
		state.update_state("Running")
		return
	if not state._raycast_middle.is_colliding():
		state.jumpstate = state.jump
		state.move_direction = -state.move_direction
		state.anim_tree["parameters/conditions/wall slide"] = false
		state.update_state("Falling")
		return
	if wall_collision_check() == wall_collision.wallClimb:
		state.update_state("WallClimb")
		return
	if wall_bounce_timer < wall_bounce_buffer:
		if  state.attempting_jump and state.controller.jumpstate:
			state.move_direction = state.camera_relative_movement.normalized()
			if state.move_direction.dot(surface_normal) < 0:
				state.move_direction = state.move_direction.bounce(surface_normal)
			if state.move_direction == Vector3.ZERO:
				state.move_direction == surface_normal
			if state.current_speed + 0.25 > 12.5:
				state.current_speed += 0.25
			else:
				state.current_speed = 12.5
			state.jumpstate = state.jump
			state.anim_tree["parameters/conditions/wall slide"] = false
			state.update_state("Jump")
	else:
		if  state.attempting_jump:
			if state.spin_allowed:
				state.move_direction = surface_normal
				state.velocity = surface_normal * 12.5
				state.current_speed = 12.5
				state.jumpstate = state.wall_spin
				state.update_state("Jump")
				return
			directional_input_handling()
			state.current_speed = 10
			state.jumpstate = state.jump
			state.anim_tree["parameters/conditions/wall slide"] = false
			state.update_state("Jump")
	state.velocity = state.calculate_velocity(-10, delta)
	pass

func directional_input_handling():
	var dir = state.camera_relative_movement.normalized()
	if state.controller.input_strength == 0:
		state.move_direction = surface_normal
		return
	if dir.dot(surface_normal) < 0:
		dir = dir.bounce(surface_normal)
	var angle = surface_normal.signed_angle_to(dir, Vector3.UP)
	if angle < -deg_to_rad(40):
		angle = deg_to_rad(40)
	elif angle > deg_to_rad(40):
		angle = -deg_to_rad(40)
	state.move_direction = dir.rotated(Vector3.UP, angle)

func reset():
	state._reset_animation_parameters()
	state.anim_tree["parameters/conditions/wall slide"] = true
	var instance = load(landing_particles).instantiate()
	add_child(instance)
	instance.global_position = state.player.global_position
	entering_angle = Vector3(state.velocity.x,0, state.velocity.z)
	var horizontal_strength = entering_angle.length()
	entering_angle = entering_angle.normalized()
	if horizontal_strength < .1:
		state.consecutive_stationary_wall_jump += 1
	wall_bounce_timer = 0
	state.velocity = Vector3.ZERO
	surface_normal = state._raycast_middle.get_collision_normal()
	surface_normal.y = 0
	state.move_direction = -surface_normal
	state.snap_vector = -surface_normal
	if state.move_direction != Vector3.ZERO:
		var temp = player.transform.looking_at(player.global_transform.origin + state.move_direction, Vector3.UP)
		if temp != Transform3D():
			player.transform = temp
	return
