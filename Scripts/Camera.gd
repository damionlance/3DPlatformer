extends Camera

onready var following = get_node("../look_at")

var up = Vector3(0,1,0)
var position
var target
var offset = Vector3(0,0,0)
var height = 7
# Called when the node enters the scene tree for the first time.
func _ready():
	position = global_transform.origin
	# on start, follow car
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	target = following.global_transform.origin
	var relativePosition = position - target
	offset = relativePosition.normalized() * 7
	offset.y = 2
	position = target + offset
	look_at_from_position(position, target, up)
	pass
