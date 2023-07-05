extends MeshInstance3D

var downTween : Tween
var doorHeight

# Called when the node enters the scene tree for the first time.
func _ready():
	doorHeight = get_aabb().size.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_activate():
	downTween = create_tween()
	if doorHeight == null:
		doorHeight = get_aabb().size.y
	downTween.tween_property(self, "position", Vector3(0, -1 * doorHeight - .2,0), 5.0).as_relative()
