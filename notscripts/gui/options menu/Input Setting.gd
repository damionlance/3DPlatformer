extends Button

var allowing_input = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.settings[name] is String:
		text = Global.settings[name]
	else:
		text = Global.settings[name].as_text()

func _pressed():
	text = ""
	var listening_for_input = load("res://scenes/ui/Input Listening.tscn").instantiate()
	add_child(listening_for_input)
	listening_for_input.input_caught.connect(_on_input_caught)

func _on_input_caught(input):
	text = input.as_text()
	
	$"../../../../../../../../../..".new_settings[name] = input
	grab_focus()
