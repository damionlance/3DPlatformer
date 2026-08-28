@tool
class_name MovementRestrictiveRope extends Node3D

## The Linear Movement Constraint is the node that manages the player's movement when they
## are attached to the rope.
@export var movement_constraint : LinearMovementConstraint
## The mesh used for rendering the rope itself. Currently these are all generated in engine.
## I do not currently support replacing them with custom meshes.
@export var mesh : MeshInstance3D
## The collider that is used to check if the player should connect to the rope.
@export var area3d : Area3D
## The collisionshape for the Area3D. This gets updated in engine whenever the anchor moves
## automatically.
@export var collision_shape : CollisionShape3D
## The anchor is an editor visual for making it easier to see where the rope is going.
## It is not visible when running the game.
@export var anchor : Node3D

## Used for tracking if the anchor position has moved so we update the mesh in engine.
## This should never ever change during runtime.
var old_anchor : Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement_constraint.type = str(get_script().get_global_name())
	movement_constraint.direction = (anchor.global_position - global_position).normalized()
	movement_constraint.anchor_pos = anchor.position
	anchor.visible = false

func _process(_delta : float) -> void:
	if Engine.is_editor_hint():
		if old_anchor != anchor.position :
			old_anchor = anchor.position
