extends KinematicBody

onready var camera_pivot : Spatial = $CameraPivot
onready var player_model = $lilfella
onready var player_anim = $lilfella/AnimationPlayer
onready var player_anim_tree = $AnimationTree
onready var camera = $CameraPivot/SpringArm/Camera
onready var particles = $lilfella/particles

export (NodePath) var shadow_path

var anim_tree

var velocity := Vector3.ZERO
var snap_vector := Vector3.ZERO

var coins = 0
var stars = 0
var time_now = 0
var shadow
var tween
var grappling := false

func _ready():
	anim_tree = player_anim_tree["parameters/playback"]
	shadow = get_node(shadow_path)

func _process(_delta):
	pass

func _physics_process(delta):
	#if grappling:
	#	velocity = move_and_slide(velocity, Vector3.UP)
	#else:
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, false)

func update_physics_data(_velocity: Vector3, _snap_vector: Vector3):
	velocity = _velocity
	snap_vector = _snap_vector
	
func add_coin():
	coins += 1
	print(coins, " coins")
	
func add_star():
	stars = 0
	print(Global.stars)
	for star in Global.stars.keys():
		if Global.stars[star]:
			stars += 1
	print(stars, " stars")
	if stars == 3:
		time_now = OS.get_unix_time()
		print("You finished in: " + str(-1 * (Global.time_start - time_now)) + ". Good job!")
