extends RigidBody3D

@onready var collision_shape
@onready var timer = $Timer
@onready var area = $Area3D

@export var gravity := 9.8
@export var stableTime := 1.0
@export var resetTime := 1.0

var main_collision_layer = collision_layer

var state := 0
var original_position
var collided := false

enum {
	wait,
	begin,
	fall,
	reset
}

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape = find_child("CollisionShape3D")
	self.freeze = true
	timer.one_shot = true
	original_position = self.global_position
	area.add_child(collision_shape.duplicate())
	area.translate(Vector3(0,.1,0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match state:
		wait:
			for body in area.get_overlapping_bodies():
				if body.name == "Player":
					state = begin
					timer.start(stableTime)
		begin:
			if timer.is_stopped():
				collision_layer = 0
				self.freeze = false
				state = fall
				timer.start(resetTime)
		fall:
			if timer.is_stopped():
				state = reset
		reset:
			_reset()
	
	pass

func _reset():
	collision_layer = main_collision_layer
	state = wait
	self.global_position = original_position
	self.freeze = true
	rotation_degrees.x = 0
	rotation_degrees.y = 0
	rotation_degrees.z = 0
	linear_velocity.x = 0
	linear_velocity.y = 0
	linear_velocity.z = 0
