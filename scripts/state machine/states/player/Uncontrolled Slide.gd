extends AerialMovement

var _state_name = "Uncontrolled Slide"

@onready var shadow_raycast = $"../../../ShadowRaycast"
# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	
	pass # Replace with function body.

func update(_delta):
	_state.current_speed = _state.velocity.length()
	_state.move_direction = _state.velocity.normalized()
	var surface_normal = shadow_raycast.get_collision_normal()
	if _state.attempting_jump:
		_player.grappling = false
		_state._jump_state = _state.jump
		_state.update_state("Jump")
		return
	if _state.current_speed < 2 and surface_normal.dot(Vector3.UP) > .85:
		_player.grappling = false
		_state.update_state("Running")
		return
	_player.rotation = Vector3.ZERO
	pass

func reset():
	_player.rotation = Vector3.ZERO
	_state._reset_animation_parameters()
	_state.anim_tree["parameters/conditions/uncontrolled slide"] = true
	_player.grappling = true
	_player.grapple_slider.linear_velocity = _player.velocity
	_state.velocity.y = 0
	pass
