extends OmniLight3D

var rng = RandomNumberGenerator.new()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	light_energy = 1
	

func _process(delta):
	var green = rng.randf_range(0.0, 0.78)
	light_color = lerp(light_color, Color(1.0, green, 0.0, 1.0), 0.15)
