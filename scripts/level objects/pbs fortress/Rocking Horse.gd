@tool
extends interactive_button

@export var target_position : Vector3
var rocking_with_player := false
@onready var animation_player = $"rocking horse/AnimationPlayer"
var sweet_spots

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	_player = get_tree().current_scene.find_child("Player")
	animation_player.assigned_animation = "Rocking"
	sweet_spots = [animation_player.current_animation_length/2-animation_player.current_animation_length/4, animation_player.current_animation_length/2+animation_player.current_animation_length/4]
	for property in properties:
		add_to_group(property)
	$"Target Position".global_position = target_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		var aim_direction = $"Target Position".global_position
		aim_direction.y = global_position.y
		if aim_direction != global_position:
			look_at(aim_direction, Vector3.UP)
		target_position = $"Target Position".global_position
	if rocking_with_player == true:
		_player.global_position = $"Saddle".global_position


func _activate():
	if not inactive:
		_on_body_exited(_player)
		inactive = true
		rocking_with_player = true
		_player._state.update_state("Rocking Horse")
		_player.rotation.y = rotation.y
		_player._state._current_state.horse = self
