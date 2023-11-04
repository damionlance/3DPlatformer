extends Control

signal input_caught(event)

var input_valid = false

func _ready():
	grab_focus()

func _input(event):
	if event.is_pressed(): input_valid = true
	if input_valid:
		if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
			if not event.is_pressed():
				emit_signal("input_caught", event)
				queue_free()
