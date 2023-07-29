extends OmniLight3D

var rng = RandomNumberGenerator.new()
var _player
var space_state
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	space_state = get_world_3d().direct_space_state
	_player = get_tree().get_current_scene().find_child("Player")
	light_energy = 1
	

func _process(delta):
	var green = rng.randf_range(0.0, 0.78)
	light_color = lerp(light_color, Color(1.0, green, 0.0, 1.0), 0.15)
	light_color = Color.CORAL
	if _player != null and (_player.global_position - global_position).length() < 30:
		visible = true
