extends Node3D
@tool

func _ready():
	self.position.x = 0
	self.position.z = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		self.position.x = 0
		self.position.z = 0
	pass
