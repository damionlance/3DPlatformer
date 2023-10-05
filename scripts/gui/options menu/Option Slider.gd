extends HSlider

@onready var options_menu = find_parent("Options Menu")

# Called when the node enters the scene tree for the first time.
func _ready():
	value = Global.settings[name]
	connect("value_changed", _on_value_changed)

func _on_value_changed(value):
	options_menu.new_settings[name] = value

