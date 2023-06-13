extends StaticBody3D

var downTween : Tween
var doorHeight

# Called when the node enters the scene tree for the first time.
func _ready():
	doorHeight = get_parent().get_aabb().size.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_activate():
	downTween = create_tween()
	downTween.tween_property(get_parent(), "position", Vector3(0, -1 * doorHeight,0), 2.0).as_relative()
	
	
