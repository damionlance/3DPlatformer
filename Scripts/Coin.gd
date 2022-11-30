extends Area

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var taken = false
onready var mesh = $CSGCylinder

signal coinCollected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	# Rotate
	rotate(Vector3(0, 0, 1), .1)
	
	if taken:
		queue_free()

func _on_Area_body_entered(body):
	if not taken and body is preload("res://Scripts/Player.gd"):
		taken = true
		body.add_coin()
		emit_signal("coinCollected")
		
