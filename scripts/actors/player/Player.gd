extends CharacterBody3D

@onready var camera_pivot : Node3D = $CameraPivot
@onready var player_model = $lilfella
@onready var player_anim = $lilfella/AnimationPlayer
@onready var player_anim_tree = $AnimationTree
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
@onready var state = $StateMachine
@onready var grapple_slider = $GrappleSlider
@onready var anim_tree = player_anim_tree["parameters/playback"]
@onready var raycasts := $"Raycast Handler"

@onready var coin_sounds = $"Sounds/Coin Collected"

var properties := ["pleasant_smelling", "hydrophobic"]
var has_fella := true

var friction := 0.9

var jump_state := 0
enum {
	no_jump,
	jump,
	jump2,
	jump3,
	long_jump,
	spin_jump,
	wall_spin,
	side_flip,
	dive,
	rollout,
	popper_bounce,
	ground_pound,
	quick_getup,
	bonk
}


var inertia := 1

var time_now = 0
var tween
var grappling := false
var popperBounce := false
var popperAngle := Vector3.ZERO

var delta_v := Vector3.ZERO
@onready var facing_direction := Vector3(cos(rotation.y), 0, sin(rotation.y))

var collectables_loaded = false

var last_safe_transform : Transform3D

var previous_horizontal_velocity := Vector3.ZERO

func _force_reset():
	get_tree().reload_current_scene()

func _ready():
	if "is_level_preview" in get_parent():
		if get_parent().is_level_preview:
			queue_free()
	if not "level_loaded" in get_tree().get_current_scene():
		queue_free()
		return
	
	if not has_fella:
		$FriendoHomingNode.queue_free()
	
	for property in properties:
		add_to_group(property)
	
	set_motion_mode(CharacterBody3D.MOTION_MODE_GROUNDED)
	grapple_slider.set_as_top_level(true)
	set_floor_constant_speed_enabled(false)
	set_floor_stop_on_slope_enabled(false)
	set_floor_max_angle(deg_to_rad(60))
	set_floor_snap_length(1.0)
	set_max_slides(6)
	set_up_direction(Vector3.UP)

func _physics_process(delta):
	velocity += -Vector3(velocity.x * friction, velocity.y, velocity.z * friction) if delta_v == Vector3.ZERO else delta_v * delta
	
	move_and_slide()
	velocity = get_real_velocity()

func add_coin(coin_name):
	if not coin_name.contains("LEVELCOIN"):
		Global.UPDATE_COLLECTIBLES("COIN", Global.WORLD_COLLECTIBLES["COIN"] + 1)
	else:
		Global.UPDATE_COLLECTIBLES("LEVEL COIN", Global.WORLD_COLLECTIBLES["LEVEL COIN"] + 1)
	get_node("HUD/MarginContainer/counters/" + coin_name.to_lower())._increase_coins()
	coin_sounds.pitch_scale = randf() + .7
	coin_sounds.play()
	return true

func _on_collectable_touched(collectable_name):
	if collectable_name == "pool coin":
		return
	get_node("HUD/MarginContainer/counters/" + collectable_name)._enter_screen()

func add_body(body, string):
	$"HUD/MarginContainer".add_body(body, string)
	pass

func remove_body(body):
	$"HUD/MarginContainer".remove_body(body)
	pass

func activate_dialogue_box(dialogue_path, body):
	$"HUD/MarginContainer".start_dialogue(dialogue_path, body)
	if state.current_speed > 5:
		player_anim_tree["parameters/conditions/stop"] = false
	player_anim_tree["parameters/conditions/running"] = false
	state.current_speed = 0
	state.move_direction = Vector3.ZERO

func get_current_held_object() -> Object:
	return $HoldableObjectNode.current_object

func drop_current_held_object():
	$HoldableObjectNode.drop_object()

func release_current_held_object():
	$HoldableObjectNode.release_object()

func _add_split(split_name):
	$"splits/MarginContainer/Run Time Timers"._add_split(split_name)
