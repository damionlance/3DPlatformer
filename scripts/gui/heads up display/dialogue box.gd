extends Panel
var i = 0
var ready_for_input = false
var dialogue : Dictionary

func add_new_text(new_text):
	$MarginContainer/RichTextLabel.text = "[center]" + new_text + "[/center]"

func display_dialogue() -> bool:
	if i >= dialogue.size():
		return true
	elif dialogue[str(i)]:
		add_new_text(dialogue[str(i)]["text"])
	if Input.is_action_just_pressed("Jump") and ready_for_input:
		i += 1
	elif not Input.is_action_pressed("Jump"):
		ready_for_input = true
	if Input.is_action_just_pressed("Throw"):
		return true
	return false

func reset():
	i = 0
	dialogue.clear()
