extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_coin_body_entered(body):
	if body.get_name() == "Player":
		if body.add_coin():
			queue_free()
