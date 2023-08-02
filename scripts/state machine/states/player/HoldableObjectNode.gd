extends Node3D

var current_object = null
@onready var one_handed_position = $"../lilfella/rig/Skeleton3D/RightHand"
@onready var _state = $"../StateMachine"

var object_original_collision_layer

func _process(_delta):
	if current_object == null: 
		_state.restricted_movement = false
		return
	
	if current_object.is_in_group("holdable"):
		if current_object.is_in_group("heavy"):
			current_object.global_position = global_position
		else:
			current_object.global_position = one_handed_position.global_position

func hold_object(object):
	
	current_object = object
	object.get_parent().remove_child(object)
	self.add_child(object)
	object_original_collision_layer = object.get_collision_layer()
	object.set_collision_layer(0)
	
	if current_object.is_in_group("heavy"):
		_state.restricted_movement = true

func drop_object():
	current_object.set_collision_layer(object_original_collision_layer)
	var zone = ""
	if "zone" in current_object :
		zone = current_object.zone
		self.remove_child(current_object)
		get_node(current_object.zone).add_child(current_object)
	else:
		self.remove_child(current_object)
		self.owner.add_child(current_object)
	current_object.global_position = global_position
	current_object = null

func release_object():
	current_object.set_collision_layer(object_original_collision_layer)
	current_object = null
