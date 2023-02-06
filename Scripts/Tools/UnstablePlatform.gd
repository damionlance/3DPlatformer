extends RigidBody

onready var collision_shape = $CollisionShape
onready var timer = $Timer
onready var area = $Area

export var gravity := 9.8
export var stableTime := 1.0
export var resetTime := 1.0

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
	timer.one_shot = true
	original_position = global_translation
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
				mode = RigidBody.MODE_RIGID
				state = fall
				timer.start(resetTime)
		fall:
			if timer.is_stopped():
				state = reset
		reset:
			_reset()
	
	pass

func _reset():
	state = wait
	global_translation = original_position
	mode = RigidBody.MODE_STATIC
	rotation_degrees.x = 0
	rotation_degrees.y = 0
	rotation_degrees.z = 0
	linear_velocity.x = 0
	linear_velocity.y = 0
	linear_velocity.z = 0
