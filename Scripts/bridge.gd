extends StaticBody3D

@onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_body_entered(body):
	if body.name == "Player":
		anim.play("bridgeActivate")


func _on_button_2_body_entered(body):
	if body.name == "Player":
		anim.play("bridgeActivate")