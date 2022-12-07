extends SpotLight


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var flickerTimer = get_node("Timer")

var rng = RandomNumberGenerator.new()
var state = 2
var last_state = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	flickerTimer.set_one_shot(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(flickerTimer.get_time_left())
	rng.randomize()
	var new_emission = rng.randf_range(-10.0,50.0)
	rng.randomize()
	var timer_length = rng.randf_range(-16.0, -1.0)
	
	if flickerTimer.get_time_left() == 0:
		if state == 0:
			if new_emission > 7:
				state = 2
			else:
				state = 1
			flickerTimer.stop()
			flickerTimer.start(timer_length)
		else:
			state = 0
			
	if state == 2:
			light_energy = 50
	elif state == 1:
			light_energy = 7
	else:
			light_energy = 1
			if flickerTimer.is_stopped():
				print("here?")
				flickerTimer.start(.5)
		
