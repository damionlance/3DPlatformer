extends Button

@export var action : String
var controller_action : String
var keyboard_action : String
# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.settings[name] is String:
		text = Global.settings[name]
	else:
		text = Global.settings[name].as_text()
	controller_action = InputMap.action_get_events(action)[1].as_text().replace("/","")
	var load_icon = load("res://assets/textures/input prompts/" + Global.device + "/" + controller_action + ".png")
	if load_icon != null:
		icon = load_icon
		text = ""

func _pressed():
	text = "Listening for input..."
	icon = null
	var listening_for_input = load("res://scenes/ui/Input Listening.tscn").instantiate()
	add_child(listening_for_input)
	listening_for_input.input_caught.connect(_on_input_caught)

func _on_input_caught(input):
	var load_icon = load("res://assets/textures/input prompts/" + Global.device + "/" + input.as_text().replace("/","") + ".png")
	if load_icon != null:
		icon = load_icon
		text = ""
	else:
		text = input.as_text()
	
	$"../../../../../../../".new_settings[name] = input
	grab_focus()
