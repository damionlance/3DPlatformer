extends StaticBody3D

@onready var anim = $AnimationPlayer
var lowered = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not lowered:
		if "collected" in get_parent():
			if get_parent().collected:
				anim.play("bridgeActivate")
				lowered = true
	pass


func _on_button_body_entered(body):
	if "collected" in get_parent():
		get_parent()._update_collectables(true)
	if not lowered:
		if body.name == "Player":
			anim.play("bridgeActivate")
			lowered = true
