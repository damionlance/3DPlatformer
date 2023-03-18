extends Spatial
tool

func _ready():
	self.translation.x = 0
	self.translation.z = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		self.translation.x = 0
		self.translation.z = 0
	pass
