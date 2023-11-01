extends GPUParticles3D


func _ready():
	emitting = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not emitting:
		queue_free()

