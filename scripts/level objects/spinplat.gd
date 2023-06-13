@tool
extends MeshInstance3D

var tween : Tween
var localHeight
@export var spinHeight : Vector3
@export var risingSpeed : float
@export var fallingSpeed : float

# Called when the node enters the scene tree for the first time.
func _ready():
	localHeight = global_position - spinHeight
	global_position = localHeight

func _update_localHeight(valueToUpdate):
	localHeight += valueToUpdate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		global_position = localHeight + spinHeight
		print(global_position)


func _on_spin_button_spinning(isSpin):
	tween = create_tween()
	if isSpin:
		tween.tween_property(self, "global_position", localHeight + spinHeight, (localHeight + spinHeight).length()/risingSpeed)
	else:
		tween.tween_property(self, "global_position", localHeight, (localHeight + spinHeight).length()/fallingSpeed)
