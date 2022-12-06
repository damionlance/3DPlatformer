extends Area

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var taken = false
onready var mesh = $MeshInstance

signal starCollected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	if taken:
		queue_free()
		
func _on_atopthemountain_body_entered(body):
	if not taken and body is preload("res://Scripts/Player.gd"):
		taken = true
		Global.stars["Atop the Mountain"] = true
		body.add_star()
		emit_signal("starCollected")
		get_tree().change_scene_to(load('res://TestLevels/Levels/hub.tscn'))

func _on_downthelazyriver_body_entered(body):
	if not taken and body is preload("res://Scripts/Player.gd"):
		taken = true
		Global.stars["Down the Lazy River"] = true
		body.add_star()
		emit_signal("starCollected")
		get_tree().change_scene_to(load('res://TestLevels/Levels/hub.tscn'))

func _on_pipes_body_entered(body):
	if not taken and body is preload("res://Scripts/Player.gd"):
		taken = true
		Global.stars["Pipes!"] = true
		body.add_star()
		emit_signal("starCollected")
		get_tree().change_scene_to(load('res://TestLevels/Levels/hub.tscn'))

func _on_atopthemountain_ready():
	if Global.stars["Atop the Mountain"]:
		queue_free()
		
func _on_downthelazyriver_ready():
	if Global.stars["Down the Lazy River"]:
		queue_free()

func _on_pipes_ready():
	if Global.stars["Pipes!"]:
		queue_free()
