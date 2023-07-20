extends MarginContainer

@onready var camera = $"../../CameraPivot/SpringArm3D/Camera3D"
@onready var camera_pivot = $"../../CameraPivot"
@onready var dialogue_box = $"Dialogue Box"

var dialogue_prompts : Array
var talking_bodies : Array

var having_dialogue := false

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_prompts.append($"Dialogue Prompt")
	dialogue_prompts.append($"Dialogue Prompt2")
	dialogue_prompts.append($"Dialogue Prompt3")
	dialogue_prompts.append($"Dialogue Prompt4")
	dialogue_prompts.append($"Dialogue Prompt5")
	talking_bodies.resize(5)
	for prompt in dialogue_prompts:
		prompt.visible = false
	dialogue_box.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var i = 0
	for prompt in dialogue_prompts:
		if prompt.visible == true:
			var screen_position = camera.unproject_position(talking_bodies[i].global_position)
			prompt.position = screen_position
		i += 1
	if having_dialogue:
		dialogue()

func add_body(body, string):
	var i = 0
	for prompt in dialogue_prompts:
		if prompt.get_node("RichTextLabel").text == "":
			prompt.get_node("RichTextLabel").add_new_text(string)
			talking_bodies[i] = body
			prompt.visible = true
		return
		i += 1

func remove_body(remove_body):
	var i = 0
	for body in talking_bodies:
		if body == remove_body:
			dialogue_prompts[i].get_node("RichTextLabel").text = ""
			dialogue_prompts[i].visible = false
			body = null
			return
		i += 1

func start_dialogue(dialogue_path, body):
	dialogue_box.dialogue = load(dialogue_path).data
	camera_pivot.halt_input = true
	camera_pivot.target_body = body
	dialogue_box.visible = true
	get_tree().paused = true
	having_dialogue = true

func dialogue():
	if dialogue_box.display_dialogue() == true:
		dialogue_box.reset()
		get_tree().paused = false
		dialogue_box.visible = false
		camera_pivot.halt_input = false
		having_dialogue = false
