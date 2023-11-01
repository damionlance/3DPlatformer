extends MeshInstance3D

var downTween : Tween
var doorHeight

var sound = AudioStreamPlayer3D.new()
var audio_file = "res://assets/sounds/activated noises/Grinding stones.mp3"
var sfx
# Called when the node enters the scene tree for the first time.
func _ready():
	sfx = load(audio_file)
	sound.set_stream(sfx)
	sound.max_distance = 100
	sound.volume_db = 0
	sound.pitch_scale = 1
	sound.bus = "Ambient Sounds"
	add_child(sound)
	doorHeight = get_aabb().size.y

func _on_area_3d_activate():
	downTween = create_tween()
	if doorHeight == null:
		doorHeight = get_aabb().size.y
	sound.play(0.0)
	downTween.tween_property(self, "position", Vector3(0, -1 * doorHeight - .2,0), 5.0).as_relative()
	await downTween.finished
	sound.stop()
	queue_free()


func _on_goal_torch_handler_completed():
	downTween = create_tween()
	if doorHeight == null:
		doorHeight = get_aabb().size.y
	sound.play(0.0)
	downTween.tween_property(self, "position", Vector3(0, -1 * doorHeight - .2,0), 5.0).as_relative()
	await downTween.finished
	sound.stop()
