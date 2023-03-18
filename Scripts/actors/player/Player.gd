extends CharacterBody3D

@onready var camera_pivot : Node3D = $CameraPivot
@onready var player_model = $lilfella
@onready var player_anim = $lilfella/AnimationPlayer
@onready var player_anim_tree = $AnimationTree
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
@onready var _state = $StateMachine
@onready var grapple_slider = $GrappleSlider
@export var shadow_path : NodePath
@onready var anim_tree = player_anim_tree["parameters/playback"]

var properties := ["pleasant_smelling", "hydrophobic"]

var snap_vector := Vector3.ZERO
var inertia := 1

var coins = 0
# levelCoins holds all level specific coins
# 	0: pool
var levelCoins = [0]

#Deprecated
var stars = 0

var time_now = 0
var shadow
var tween
var grappling := false
var popperBounce := false
var popperAngle := Vector3.ZERO

var previous_horizontal_velocity := Vector3.ZERO

func _force_reset():
	get_tree().reload_current_scene()

func _ready():
	for property in properties:
		add_to_group(property)
	
	set_motion_mode(CharacterBody3D.MOTION_MODE_GROUNDED)
	grapple_slider.set_as_top_level(true)
	set_floor_constant_speed_enabled(false)
	set_floor_stop_on_slope_enabled(false)
	set_floor_max_angle(1.309)
	set_floor_snap_length(.2)
	set_max_slides(6)
	set_up_direction(Vector3.UP)

func _process(_delta):
	if popperBounce:
		$StateMachine._jump_state = $StateMachine.popper_bounce
		$StateMachine.update_state("Jump")
	popperBounce = false
	pass

func _physics_process(_delta):
	if not is_on_wall():
		previous_horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	if grappling:
		grapple_slider.freeze = false
		global_position = grapple_slider.global_position
		_state.velocity = grapple_slider.linear_velocity
	else:
		grapple_slider.freeze = true
		grapple_slider.global_position = global_position
		grapple_slider.global_position.y += 0.5
		set_velocity(velocity)
		move_and_slide()
	_state.velocity = velocity
	
	#print(velocity)

func update_physics_data(_velocity: Vector3, _snap_vector: Vector3):
	velocity = _velocity
	snap_vector = _snap_vector
	
func add_coin():
	coins += 1
	print(coins, " coins")
	return true
	
func add_levelcoin(level):
	levelCoins[level] += 1
	if level == 0:
		print(levelCoins[level], " Pool coins")
	else:
		print(levelCoins[level], " other coins...")
	return true
	
func add_star():
	stars = 0
	#print(Global.stars)
	for star in Global.stars.keys():
		if Global.stars[star]:
			stars += 1
	#print(stars, " stars")
	if stars == 3:
		time_now = Time.get_unix_time_from_system()
		#print("You finished in: " + str(-1 * (Global.time_start - time_now)) + ". Good job!")