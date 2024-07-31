class_name DialogueDetectionZone extends interactive_button

@export var dialogue : DialogueResource
const dialogue_box = preload("res://scenes/ui/balloon.tscn")

signal in_dialogue(enabled, body)

func _activate():
	if not inactive:
		var balloon: Node = dialogue_box.instantiate()
		add_child(balloon)
		emit_signal("in_dialogue", true, get_overlapping_bodies()[0])
		balloon.start(dialogue, "start")

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	player = get_tree().current_scene.find_child("Player")
	for property in properties:
		add_to_group(property)

func _on_child_exiting_tree(node: Node) -> void:
	player.state_chart.set_expression_property("locked_in_dialogue", false)
	emit_signal("in_dialogue", false, null)
