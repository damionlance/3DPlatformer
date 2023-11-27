extends Button

var tween
var starting_position := Vector2(-500, -500)

var audioplayer = AudioStreamPlayer.new()
var audio_stream = load("res://assets/sounds/UI Noises/button.ogg")

@onready var original_text = $"MarginContainer/RichTextLabel".text

func _ready():
	connect("focus_entered", _on_focus_entered)
	connect("focus_exited", _on_focus_exited)
	audioplayer.bus = "Sound Effect"
	audioplayer.set_stream(audio_stream)
	add_child(audioplayer)

func _process(delta):
	if starting_position == Vector2(-500,-500):
		starting_position = position

func _on_focus_entered():
	audioplayer.play()
	move_tween()

func get_original_position():
	starting_position = position

func _on_focus_exited():
	if tween != null and tween.is_running():
		tween.stop()
	$"MarginContainer/RichTextLabel".text = original_text
	position = starting_position

func move_tween():
	$"MarginContainer/RichTextLabel".text = "[wave]" + $"MarginContainer/RichTextLabel".text
	if tween!= null and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:x", 10, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).as_relative()
	tween.tween_property(self, "position:x", -10, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).as_relative()
