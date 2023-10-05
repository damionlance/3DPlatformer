@tool
extends Node3D

var tween : Tween
@export var button : NodePath
@export var initial_position : Vector3
@export var spinHeight : Vector3
@export var risingSpeed : float
@export var fallingSpeed : float
var previous_position := Vector3.ZERO
var audio_player := AudioStreamPlayer3D.new()
var audio_stream_rising : AudioStream
var audio_stream_falling : AudioStream

func _ready():
	global_position = initial_position
	await get_node(button).ready
	get_node(button).activate.connect(_on_stomp_button_velocity_trigger_fired)
	audio_stream_rising = load("res://assets/sounds/activated noises/Fast Stone Grind.mp3")
	audio_stream_falling = load("res://assets/sounds/activated noises/Grinding stones.mp3")
	add_child(audio_player)
	audio_player.bus = "Ambient Sounds"
	audio_player.max_db = 5
	audio_player.global_position = global_position
	var size
	

func _process(_delta):
	if Engine.is_editor_hint():
		global_position = initial_position + spinHeight
	else:
		get_child(0).constant_linear_velocity = position - previous_position
		previous_position = position

func _on_spin_button_spinning(isSpin):
	if tween != null and tween.is_running():
		tween.stop()
	tween = create_tween()
	var distance
	if isSpin:
		distance = (global_position - (initial_position + spinHeight)).length()
		tween.tween_property(self, "global_position", initial_position + spinHeight, distance/risingSpeed)
	else:
		distance = (global_position - initial_position).length()
		tween.tween_property(self, "global_position", initial_position, distance/fallingSpeed)


func _on_stomp_button_velocity_trigger_fired(_body):
	if tween != null and tween.is_running():
		tween.stop()
	if audio_player.playing:
		audio_player.stop()
	audio_player.set_stream(audio_stream_rising)
	audio_player.play()
	tween = create_tween()
	var distance = (global_position - (initial_position + spinHeight)).length()
	tween.tween_property(self, "global_position", initial_position + spinHeight, .35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	await tween.finished
	if audio_player.playing:
		audio_player.stop()
	audio_player.set_stream(audio_stream_falling)
	audio_player.play()
	tween = create_tween()
	var downDistance = (global_position - initial_position).length()
	tween.tween_property(self, "global_position", initial_position, downDistance/fallingSpeed)
	await tween.finished
	audio_player.stop()
