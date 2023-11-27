extends AerialMovement

var state_name = "Uncontrolled Slide"

@onready var shadow_raycast = $"../../../ShadowRaycast"
# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	
	pass # Replace with function body.

func update(_delta):
	state.current_speed = state.velocity.length()
	state.move_direction = state.velocity.normalized()
	var surface_normal = shadow_raycast.get_collision_normal()
	if state.attempting_jump:
		player.grappling = false
		state.jump_state = state.jump
		state.update_state("Jump")
		return
	if state.current_speed < 2 and surface_normal.dot(Vector3.UP) > .85:
		player.grappling = false
		state.update_state("Running")
		return
	player.rotation = Vector3.ZERO
	pass

func reset():
	player.rotation = Vector3.ZERO
	state._reset_animation_parameters()
	state.anim_tree["parameters/conditions/uncontrolled slide"] = true
	player.grappling = true
	player.grapple_slider.linear_velocity = player.velocity
	state.velocity.y = 0
	pass
