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
	set_motion_mode(CharacterBody3D.MOTION_MODE_GROUNDED)
	grapple_slider.set_as_top_level(true)
	set_floor_constant_speed_enabled(false)
	set_floor_stop_on_slope_enabled(false)
	set_floor_max_angle(PI/4)
	set_floor_snap_length(.2)
	set_max_slides(6)
	set_up_direction(Vector3.UP)

func _process(_delta):
	if popperBounce:
		$StateMachine._jump_state = $StateMachine.popper_bounce
		$StateMachine.update_state("Jump")
	popperBounce = false
	pass

func _physics_process(delta):
	if grappling:
		grapple_slider.freeze = false
		global_position = grapple_slider.global_position
		_state.velocity = grapple_slider.linear_velocity
	else:
		grapple_slider.freeze = true
		grapple_slider.global_position = global_position
		set_velocity(velocity)
		move_and_slide()
	var collision = get_last_slide_collision()
	if collision:
		if collision.get_collider() is RigidBody3D:
			collision.get_collider().apply_impulse(-collision.get_normal() * inertia, collision.get_position())

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
		time_now = Time.get_unix_time_from_system()
		print("You finished in: " + str(-1 * (Global.time_start - time_now)) + ". Good job!")
