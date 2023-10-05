extends DirectionalLight3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.settings["Shadow Mode"] == "Disabled":
		shadow_enabled = false
	else:
		shadow_enabled = true
