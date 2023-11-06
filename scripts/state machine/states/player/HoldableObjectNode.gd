extends Node3D

var current_object = null
var one_handed_position
var _state

var object_original_collision_layer
var object_original_collision_mask

func _ready():
	one_handed_position = get_parent().find_child("RightHand", true)
	_state = get_parent().find_child("StateMachine", false)

func _process(_delta):
	if current_object == null:
		if _state != null:
			_state.restricted_movement = false
		return
	
	if current_object.is_in_group("holdable"):
		if current_object.is_in_group("heavy"):
			current_object.global_position = global_position
		else:
			current_object.global_position = one_handed_position.global_position

func hold_object(object):
	current_object = object
	current_object.position = Vector3.ZERO
	current_object.freeze = true
	object.remove_from_group("holdable")
	if object.get_parent() != null:
		object.get_parent().remove_child(object)
	self.add_child(object)
	object_original_collision_layer = object.get_collision_layer()
	object_original_collision_mask = object.get_collision_mask()
	object.set_collision_layer(0)
	object.set_collision_mask(0)
	
	if current_object.is_in_group("heavy"):
		if _state != null:
			_state.restricted_movement = true

func drop_object():
	current_object.set_collision_layer(object_original_collision_layer)
	current_object.set_collision_mask(object_original_collision_mask)
	current_object.add_to_group("holdable")
	current_object.position = Vector3.ZERO
	current_object.freeze = false
	var zone = ""
	if "zone" in current_object :
		zone = current_object.zone
		self.remove_child(current_object)
		get_node(current_object.zone).add_child(current_object)
	else:
		self.remove_child(current_object)
		get_tree().get_current_scene().add_child(current_object)
	current_object.global_position = global_position
	current_object = null

func release_object():
	current_object.set_collision_layer(object_original_collision_layer)
	current_object.set_collision_mask(object_original_collision_mask)
	current_object.freeze = false
	current_object = null
