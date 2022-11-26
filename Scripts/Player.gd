extends KinematicBody

onready var spring_arm : SpringArm = $SpringArm
onready var player_model = $Player/PlayerModel
onready var player_anim = $Player/AnimationPlayer
onready var player_anim_tree = $AnimationTree

var animations = ['Idle0', 'Running', 'Jumping', 'FallALoop']

var coins = 0

func _ready():
	for animation in animations:
		animation = player_anim.get_animation(animation)	
		animation.loop = true

func _process(_delta):
	spring_arm.translation = translation

func add_coin():
	coins += 1
	print(coins, " coins")
