@tool
extends interactive_button

@export var target_position : Vector3
var rocking_withplayer := false
@onready var animationplayer = $"rocking horse/AnimationPlayer"
var sweet_spots

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	player = get_tree().current_scene.find_child("Player")
	animationplayer.assigned_animation = "Rocking"
	sweet_spots = [animationplayer.current_animation_length/2-animationplayer.current_animation_length/4, animationplayer.current_animation_length/2+animationplayer.current_animation_length/4]
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
	if rocking_withplayer == true:
		player.global_position = $"Saddle".global_position


func _activate():
	if not inactive:
		_on_body_exited(player)
		inactive = true
		rocking_withplayer = true
		player.state.update_state("Rocking Horse")
		player.rotation.y = rotation.y
		player.state._currentstate.horse = self
