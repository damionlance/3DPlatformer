extends Node

var state_dictionary : Dictionary

var level_loaded = false

var _currentstate = null
var _previousstate = null

@export var HP := 9

var target = null

var restricted_movement := false

var velocity := Vector3.ZERO
var current_speed := 0.0
var current_direction := Vector3(0,0,1)
@export var max_speed := 10.0

@onready var body = get_parent()
@onready var player = get_parent().owner.find_child("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	if not "level_loaded" in get_tree().get_current_scene():
		get_parent().queue_free()
	get_tree().get_current_scene().connect("level_loaded", set_level_loaded)
	update_state("Idle")
	pass

func _process(delta):
	if body.is_on_floor():
		velocity.y = 0
	if level_loaded != true:
		return
	_currentstate.update(delta)
	update_physics_data(velocity)

func update_state( newstate ):
	_previousstate = _currentstate
	_currentstate = state_dictionary[newstate]
	_currentstate.reset()

func update_physics_data(velocity):
	var lookdir = atan2(current_direction.x, current_direction.z)
	body.rotation.y = lookdir
	velocity += current_direction * current_speed
	body.velocity = velocity

func set_level_loaded():
	level_loaded = true
