extends ShapeCast3D

@export var requiredSpeed := 0.0
@export var ground_pound := true

@onready var original_position = get_parent().global_position
@onready var _parent = get_parent()
@onready var height = get_parent().get_aabb().size.y
@onready var particles = $GPUParticles3D
@onready var audio_player = AudioStreamPlayer3D.new()
@onready var audio_stream = load("res://assets/sounds/activated noises/Chunking.mp3")
@onready var _player = get_tree().get_current_scene().find_child("Player")

signal activate(body)
var active := false
var activatable := true
var is_depressed := false

var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(get_parent().mesh, 0)
	var verts = []
	for i in mdt.get_vertex_count():
		verts.append(mdt.get_vertex(i))
	var collisionshape = ConvexPolygonShape3D.new()
	collisionshape.points = PackedVector3Array(verts)
	shape = collisionshape
	position = Vector3.UP
	audio_player.bus = "Ambient Sounds"
	audio_player.set_stream(audio_stream)
	audio_player.volume_db = -14
	add_child(audio_player)

func _physics_process(_delta):
	if _player == null:
		return
	if abs((_player.global_position - global_position).length()) > 5:
		return
	force_shapecast_update()
	var bodies = get_collision_count()
	if active and bodies == 0:
		_reset()
	if bodies != 0 and not is_depressed:
		_slightly_depress()
	elif bodies == 0:
		is_depressed = false
		_reset()
	for i in bodies:
		if ground_pound:
			_ground_pound_test(get_collider(i))
		else:
			_velocity_test(get_collider(i))

func _slightly_depress():
	is_depressed = true
	if tween != null and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_property(get_parent(), "global_position", original_position - Vector3(0, height/3.0, 0), .3).set_trans(Tween.TRANS_BOUNCE)

func _ground_pound_test(body):
	if body.name == "Player":
		if body._state._jump_state ==  body._state.ground_pound:
			emit_signal("activate", body)
			activatable = false
			active = true
			_slam_down()

func _velocity_test(body):
	if body is CharacterBody3D:
		if body.velocity.y < requiredSpeed:
			emit_signal("activate",body)
			activatable = false
			active = true
	if body is RigidBody3D:
		if body.linear_velocity.y < requiredSpeed:
			emit_signal("activate", body)
			activatable = false
			active = true

func _reset():
	if tween != null and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_property(get_parent(), "global_position", original_position, 1)

func _slam_down():
	if tween != null and tween.is_running():
		tween.stop()
	particles.emitting = true
	audio_player.play()
	tween = create_tween()
	tween.tween_property(get_parent(), "global_position", original_position - Vector3(0, height, 0), .1)

