extends Node
class_name FriendoStuck

#private variables
var _state_name = "StuckToWall"
#onready variables
onready var _state = get_parent()
onready var _friendo = get_parent().get_parent()
onready var _grapple = $"../../Grapple"

onready var _grapple_raycast = $"../../../../GrappleRaycast"
# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

var last_distance

func update(_delta):
	# State processing
	if not _state._player.grappling:
		if _grapple.get_child(0).get_child(0):
			_grapple.get_child(0).get_child(0).queue_free()
		_state.update_state("Idle")
		return
	
	var distance = (_state._player.global_transform.origin - _friendo.global_transform.origin).length()
	if _state._controller._throw_state != 0:
		if not _grapple.get_child(0).get_child(0) and distance >= last_distance:
			_grapple.translation = _friendo.translation
			_grapple.scale.x = distance * 2 + 2
			_grapple.scale.y = distance * 2 + 2
			_grapple.scale.z = distance * 2 + 2
			_grapple.get_node("grappleSphereCollider").create_trimesh_collision()
			_grapple.get_child(0).get_child(0).set_collision_mask(_grapple.get_collision_mask())
			_grapple.get_child(0).get_child(0).set_collision_layer(_grapple.get_collision_layer())
	_grapple_raycast.cast_to = _grapple_raycast.to_local(_friendo.global_transform.origin)
	last_distance = distance
	pass

func reset():
	# Delete any previous colliders
	if is_instance_valid(_grapple.get_node("grappleSphereCollider/StaticBody")):
		_grapple.get_node("grappleSphereCollider/StaticBody").queue_free()
	
	last_distance = 9999
	_friendo.velocity = Vector3.ZERO
	_state.move_direction = Vector3.ZERO
	_state.movement_speed = 0.0
	_friendo.emit_signal("hit_wall", _friendo.global_transform.origin)
	pass
