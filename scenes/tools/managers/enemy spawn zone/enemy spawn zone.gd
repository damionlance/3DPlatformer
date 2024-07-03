class_name EnemySpawnZone
extends Node3D

## Set the enemy type
@export var enemy_type : PackedScene = null
var _instanced_enemy_scene : Enemy = null
## Change how many enemies spawn per zone
@export var number_of_enemies_to_spawn : int = 3

@onready var area_3d := $"Area3D"
@onready var collision_shape := $"Area3D/CollisionShape3D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if enemy_type != null:
		_instanced_enemy_scene = enemy_type.instantiate()
		if not _instanced_enemy_scene is Enemy:
			print("Enemy Type is not an Enemy, check the scene!")
			queue_free()
	else:
		print("No enemy type scene added!")
		queue_free()
	for i in number_of_enemies_to_spawn:
		var enemy = _instanced_enemy_scene.duplicate()
		add_child(enemy)
		enemy.owner = self
		enemy.position = get_location_within_spawn_zone()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_location_within_spawn_zone() -> Vector3:
	var location = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * collision_shape.shape.radius
	return location
