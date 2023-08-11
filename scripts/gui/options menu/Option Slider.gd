extends HSlider



# Called when the node enters the scene tree for the first time.
func _ready():
	value = Global.settings[name]
	connect("value_changed", _on_value_changed)

func _on_value_changed(value):
	$"../../../../../../".new_settings[name] = value

