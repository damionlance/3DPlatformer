extends CheckButton


# Called when the node enters the scene tree for the first time.
func _ready():
	button_pressed = Global.settings["VSync"]
