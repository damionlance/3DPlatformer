extends Panel
var i = 0
var ready_for_input = false
var dialogue : Dictionary
@onready var state = $"../../../StateMachine"

func add_new_text(new_text):
	state.attempting_jump = false
	$MarginContainer/RichTextLabel.text = "[center]" + new_text + "[/center]"

func display_dialogue() -> bool:
	if i >= dialogue.size():
		if Input.is_action_just_released("Jump"):
			return true
	elif dialogue[str(i)]:
		add_new_text(dialogue[str(i)]["text"])
	if Input.is_action_just_pressed("Jump") and ready_for_input:
		i += 1
	elif not Input.is_action_pressed("Jump"):
		ready_for_input = true
	if Input.is_action_just_released("Throw"):
		return true
	return false

func reset():
	i = 0
	dialogue.clear()
