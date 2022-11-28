extends KinematicBody

onready var camera_pivot : Spatial = $CameraPivot
onready var player_model = $lilfella/Armature
onready var player_anim = $lilfella/AnimationPlayer
onready var player_anim_tree = $AnimationTree

var animations = ['Idle', 'Run', 'Jump', 'Fall']

var coins = 0

func _ready():
	for animation in animations:
		animation = player_anim.get_animation(animation)

func _process(_delta):
	camera_pivot.translation = translation

func add_coin():
	coins += 1
	print(coins, " coins")

func _on_Area_coinCollected():
	pass # Replace with function body.
