extends Node
class_name FriendoStuck

#private variables
var _state_name = "StuckToWall"
#onready variables
onready var _state = get_parent()
onready var _friendo = get_parent().get_parent()
onready var _grapple = $"../../Grapple"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(_delta):
	# State processing
	if _state._controller._throw_state == _state._controller.throw_released:
		_grapple.get_child(0).get_child(0).queue_free()
		_state.update_state("Idle")
	
	pass

func reset():
	# Delete any previous colliders
	if is_instance_valid(_grapple.get_node("grappleSphereCollider/StaticBody")):
		_grapple.get_node("grappleSphereCollider/StaticBody").queue_free()
	
	var distance = (_state._player.global_transform.origin - _friendo.global_transform.origin).length()
	print(distance)
	_grapple.scale.x = distance * 2
	_grapple.scale.y = distance * 2
	_grapple.scale.z = distance * 2
	_grapple.get_node("grappleSphereCollider").create_trimesh_collision()
	
	_state.move_direction = Vector3.ZERO
	_state.movement_speed = 0.0
	_friendo.emit_signal("hit_wall", _friendo.global_transform.origin)
	pass
