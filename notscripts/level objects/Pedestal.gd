extends interactive_button

@onready var object_position = $"Object Location"

var current_body = null
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("interactable")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_body_exited(body):
	if body.name == "Player":
		player = null
		current_body = null
		body.remove_body(self)
		inactive = false


func _on_body_entered(body):
	if body.name == "Player":
		player = body
		if body.get_current_held_object() != null:
			current_body = body.get_current_held_object()
			body.add_body(self, "[img]res://assets/textures/input prompts/active input/Jump.png[/img]")

func _activate():
	if current_body != null:
		current_body.reparent(self)
		player.release_current_held_object()
		current_body.global_position = object_position.global_position
	collected = true
	Global.UPDATE_COLLECTIBLES(get_parent().name, collected)
	activated = true
