extends AerialMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var state_name = "Wall Slide"
var entering_angle : Vector3
var surface_normal : Vector3

var wall_bounce_buffer := 5
var wall_bounce_timer := 0

var falling := false

var entering_gravity := 0.0
var jump_speed := 10.0

var forwards
var right

#onready variables
@onready var landing_particles = "res://scenes/particles/landing particles.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(delta):
	delta_v = Vector3.ZERO
	
	if raycasts.is_on_floor:
		state.update_state("Running")
		return
	if not raycasts.is_on_wall:
		player.jump_state = 1
		state.update_state("Falling")
		return
	if controller.attempting_jump:
		player.jump_state = 1
		player.velocity = directional_input_handling() * (jump_speed * delta)
		state.update_state("Jump")
		return
	
	if player.velocity.y > 0:
		delta_v.y = entering_gravity * delta
	else:
		delta_v.y = constants._spin_jump_gravity * delta
		if not falling:
			player.velocity = Vector3(0, player.velocity.y, 0)
			falling = true
	
	player.snap_vector = -raycasts.closest_wall_normal
	player.delta_v = delta_v

func directional_input_handling() -> Vector3:
	var dir = controller.camera_relative_movement.normalized()
	if controller.input_strength == 0:
		return surface_normal
	if dir.dot(surface_normal) < 0:
		dir = dir.bounce(surface_normal)
	var angle = surface_normal.signed_angle_to(dir, Vector3.UP)
	if angle < -deg_to_rad(40):
		angle = deg_to_rad(40)
	elif angle > deg_to_rad(40):
		angle = -deg_to_rad(40)
	return dir.rotated(Vector3.UP, angle)

func reset(_delta):
	falling = false
	entering_angle = player.velocity
	entering_angle = entering_angle.normalized()
	
	if player.velocity.y < 0:
		falling = true
		player.velocity = Vector3(0, player.velocity.y, 0)
	
	entering_gravity = $"../Jump".current_jump_gravity
	
	surface_normal = raycasts.closest_wall_normal
	player.snap_vector = -surface_normal
	return
