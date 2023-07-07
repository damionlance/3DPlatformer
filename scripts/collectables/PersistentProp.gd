extends Collectable

var was_collected := false

# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if collected and not was_collected:
		was_collected = true
		Global.UPDATE_COLLECTIBLES(name, collected)
	pass
