extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var numStars = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	for item in Global.stars.keys():
		if Global.stars[item]:
			numStars += 1
	text = String(numStars)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
