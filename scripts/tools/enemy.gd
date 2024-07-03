class_name Enemy
extends CharacterBody3D

var spawn_zone : EnemySpawnZone = null

var movement_direction := Vector3.FORWARD

@export var max_speed : float = 0.0
@export var enemy_detection_range : float = 10.0
@onready var player := get_tree().get_first_node_in_group("player")
var floor_alignment_raycast : RayCast3D = null
var state_chart : StateChart = null

func apply_friction(delta : float) -> void:
	var forward_velocity = movement_direction
	forward_velocity *= movement_direction.dot(velocity)
	var lateral_velocity = velocity - forward_velocity
	
	lateral_velocity = lerp(lateral_velocity, Vector3.ZERO, 3 * delta) 
	
	if forward_velocity.length() > max_speed * delta or forward_velocity.dot(movement_direction) < 0:
		forward_velocity = lerp(forward_velocity, Vector3.ZERO, 3 * delta)
	var temp = velocity.y
	velocity = forward_velocity + lateral_velocity
	velocity.y = temp
	if velocity.length() < 1 and movement_direction == Vector3.ZERO:
		velocity = Vector3(0, velocity.y, 0)

func align_to_floor(_delta) -> void:
	var floor_normal = floor_alignment_raycast.get_collision_normal()
	if floor_normal == Vector3.ZERO:
		return
	var xform = global_transform
	var new_y = floor_normal
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	$"%Body".global_transform = $"%Body".global_transform.interpolate_with(xform, 0.1)

func look_for_player(_delta : float) -> void:
	if (player.global_position - global_position).length() < enemy_detection_range:
		var player_direction = (player.global_position - global_position)
		player_direction.y = 0
		player_direction = player_direction.normalized()
		
		if movement_direction.dot(player_direction) > 0.8:
			state_chart.send_event("pursue player")
