extends StaticBody3D

@onready var collision_shape
@onready var timer = $Timer
@onready var area = $Area3D

@export var stable_time := 1.0
@export var distance_to_fall := 30
@export var fall_time := 2.5
@export var reset_time := 0.0

var previous_location

var tween

var main_collision_layer = collision_layer

var original_position
var detected := false

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape = find_child("CollisionShape3D")
	original_position = self.global_position
	previous_location = self.global_position
	area.add_child(collision_shape.duplicate())
	area.translate(Vector3(0,.1,0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	constant_linear_velocity = global_position - previous_location
	previous_location = global_position
	if not detected:
		for body in area.get_overlapping_bodies():
			if body.name == "Player":
				detected = true
				fall()

func fall():
	tween = create_tween()
	var temp = Vector3(0,distance_to_fall,0)
	tween.tween_property(self, "global_position", global_position - temp, fall_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART).set_delay(stable_time)
	tween.tween_callback(_reset)

func _reset():
	if tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.tween_property(self, "global_position", original_position, reset_time).set_delay(reset_time)
	await tween.finished
	detected = false
