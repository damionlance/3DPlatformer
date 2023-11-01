extends Control

var game_paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.color = Color(0,0,0,0)
	$RichTextLabel["theme_override_colors/default_color"] = Color(255,255,255,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if game_paused:
		get_tree().paused = true
		if Input.is_action_just_pressed("Jump"):
			get_tree().paused = false
			get_tree().change_scene_to_packed(load("res://scenes/ui/title screen.tscn"))

func _pause_game():
	game_paused = true


func _on_game_end_zone_body_entered(body):
	if body.name == "Player":
		visible = true
		body._add_split("Game Over")
		$"ColorRect/AnimationPlayer".play("Fade to Black")
