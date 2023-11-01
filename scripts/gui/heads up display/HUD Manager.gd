extends MarginContainer

@onready var camera = $"../../CameraPivot/SpringArm3D/Camera3D"
@onready var camera_pivot = $"../../CameraPivot"
@onready var dialogue_box = $"Dialogue Box"
@onready var audio_stream = AudioStreamPlayer.new()
@onready var audio_effect = load("res://assets/sounds/UI Noises/input prompt.ogg")

var dialogue_prompts : Array
var talking_bodies : Array

var having_dialogue := false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(audio_stream)
	audio_stream.bus = "Sound Effect"
	audio_stream.set_stream(audio_effect)
	audio_stream.volume_db = -5
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
func _process(_delta):
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
			audio_stream.play()
			prompt.get_node("RichTextLabel").add_new_text(string)
			talking_bodies[i] = body
			prompt.visible = true
			var screen_position = camera.unproject_position(talking_bodies[i].global_position)
			prompt.position = screen_position
			return
		i += 1

func remove_body(removed_body):
	var i = 0
	for body in talking_bodies:
		if body == removed_body:
			dialogue_prompts[i].get_node("RichTextLabel").text = ""
			dialogue_prompts[i].visible = false
			body = null
			return
		i += 1

func start_dialogue(dialogue_path, body):
	dialogue_box.dialogue = load(dialogue_path).data
	camera_pivot.halt_input = true
	if body != null:
		camera_pivot.target_body = body
	dialogue_box.visible = true
	get_tree().paused = true
	having_dialogue = true

func _pause_enter():
	$"counters/coin"._pause_enter()
	$"counters/level coin"._pause_enter()

func _unpause_coins():
	$"counters/coin"._leave_screen()
	$"counters/level coin"._leave_screen()

func dialogue():
	if dialogue_box.display_dialogue() == true:
		$"../../StateMachine".attempting_jump = false
		dialogue_box.reset()
		get_tree().paused = false
		dialogue_box.visible = false
		camera_pivot.halt_input = false
		having_dialogue = false
		
