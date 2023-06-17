extends interactive_button

@export_file var dialogue_file
@onready var dialogue_box = self.get_owner().find_child("Player")
func _activate():
	if not inactive:
		_on_body_exited(_player)
		inactive = true
		_player.activate_dialogue_box(dialogue_file,self)
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	_player = get_tree().current_scene.find_child("Player")
	for property in properties:
		add_to_group(property)
