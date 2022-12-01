extends KinematicBody

onready var camera_pivot : Spatial = $CameraPivot
onready var player_model = $lilfella/Object
onready var player_anim = $lilfella/AnimationPlayer
onready var player_anim_tree = $AnimationTree
onready var camera = $CameraPivot/SpringArm/Camera
var anim_tree

var animations = ['Idle1', 'Run', 'Jump', 'Fall']

var coins = 0
var tween

func _ready():
	for animation in animations:
		animation = player_anim.get_animation(animation)
	anim_tree = player_anim_tree["parameters/playback"]

func _process(_delta):
	camera_pivot.translation = lerp(camera_pivot.translation, translation, .1)
	pass

func add_coin():
	coins += 1
	print(coins, " coins")
