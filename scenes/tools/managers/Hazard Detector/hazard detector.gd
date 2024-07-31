class_name HazardDetector extends Area3D

@export var hazard_physics_layer := 64
@export var death_planes_layer := 16
var hazard_collided_with : Hazard3D

signal hazard_detected(Hazard)

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_mask = hazard_physics_layer

func disable() -> void:
	collision_mask = death_planes_layer

func enable() -> void:
	collision_mask = death_planes_layer + hazard_physics_layer


func _on_body_entered(body: Node3D) -> void:
	emit_signal("hazard_detected", body)

func _on_area_entered(area: Area3D) -> void:
	emit_signal("hazard_detected", area)
