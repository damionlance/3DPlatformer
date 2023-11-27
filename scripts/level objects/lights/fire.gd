extends OmniLight3D

var rng = RandomNumberGenerator.new()
var player
var spacestate
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	spacestate = get_world_3d().direct_spacestate
	player = get_tree().get_current_scene().find_child("Player")
	light_energy = 1
	if Global.settings["Omni Light Shadows"] == "Disabled" or Global.settings["Shadow Mode"] == "Disabled":
		shadow_enabled = false
	else:
		shadow_enabled = true
	

func _process(_delta):
	var green = rng.randf_range(0.0, 0.78)
	light_color = lerp(light_color, Color(1.0, green, 0.0, 1.0), 0.15)
	light_color = Color.CORAL
	if player != null and (player.global_position - global_position).length() < 30:
		visible = true
