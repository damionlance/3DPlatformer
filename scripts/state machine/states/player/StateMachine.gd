extends Node

#public variables
var state_dictionary : Dictionary
var currentstate = null
var previousstate = null

#onready variables
@onready var body = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	if not "level_loaded" in get_tree().get_current_scene():
		queue_free()
		return
	await get_tree().get_current_scene().level_loaded
	update_state("Running")

func _process(delta):
	currentstate.update(delta)

func update_state( newstate ):
	previousstate = currentstate
	currentstate = state_dictionary[newstate]
	currentstate.reset()

