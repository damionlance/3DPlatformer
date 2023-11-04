extends CharacterBody3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var platform = $Root

var Velocity = Vector3(0, 0, 0)
var Direction = true
var Location = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Direction:
		if Location.y > 700:
			Direction = false
	else:
		if Location.y < 0:
			Direction = true
		
	if Direction:
		Velocity.y = 7
	else:
		Velocity.y = -7
	Location.y += Velocity.y
	
func _physics_process(delta):
	set_velocity(Velocity)
	move_and_slide()
	pass
