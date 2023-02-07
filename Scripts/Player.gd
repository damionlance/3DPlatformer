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
var inertia := 1

var coins = 0
var stars = 0
var time_now = 0
var shadow
var tween
var grappling := false
var popperBounce := false
var popperAngle := Vector3.ZERO


func _ready():
	anim_tree = player_anim_tree["parameters/playback"]
	shadow = get_node(shadow_path)

func _process(_delta):
	if popperBounce:
		$StateMachine.update_state("PopperBounce")
	popperBounce = false
	pass

func _physics_process(delta):
	if grappling:
		velocity = move_and_slide_with_snap(velocity, snap_vector)
	else:
		velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 4, PI/4, false)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is RigidBody:
			collision.collider.apply_impulse(collision.position, -collision.normal * inertia)
	$StateMachine.velocity = velocity

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
