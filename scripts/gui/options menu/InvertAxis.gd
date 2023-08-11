extends CheckBox

var allowing_input = false
# Called when the node enters the scene tree for the first time.
func _ready():
	button_pressed = Global.settings[name]

func _pressed():
	$"../../../../../../../".new_settings[name] = button_pressed
