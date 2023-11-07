extends GroundedMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var horse = null

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Rocking Horse"
var _fall_timer := 0

var power = 0

var rocks_before_slowing = 5
var rocks := 0

var timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	timer.one_shot = true
	add_child(timer)
	pass 

func update(delta):
	if horse != null:
		if horse.animation_player.is_playing():
			if Input.is_action_just_pressed("Jump"):
				_state.update_state("Projectile Launch")
				_state._current_state.target_position = horse.target_position
				_state._current_state.current_position = horse.global_position
				horse.rocking_with_player = false
				horse.inactive = false
				return
			if power == 0:
				horse.animation_player.stop()
			else:
				var timing = 0
				if Input.is_action_just_pressed("Forward"):
					timing = horse.animation_player.current_animation_position - horse.sweet_spots[1]
				if Input.is_action_just_pressed("Backward"):
					timing = horse.animation_player.current_animation_position - horse.sweet_spots[0]
				if timing != 0:
					print(timing)
					if timing < .2:
						power += 1
						horse.animation_player.speed_scale = 1 + (power * .2)
						timer.start(horse.animation_player.current_animation_length * 5)
				if timing == 0:
					if timer.time_left <= 0:
						power -= 1
						rocks = 0
						timer.start(horse.animation_player.current_animation_length * 5)
		else:
			if Input.is_action_just_pressed("Forward"):
				horse.animation_player.play("Rocking")
				horse.animation_player.advance(0.7)
				power = 1
				timer.start(horse.animation_player.current_animation_length * 5)
				horse.animation_player.play("Rocking")
				power = 1
				timer.start(horse.animation_player.current_animation_length * 5)
			if Input.is_action_just_pressed("Backward"):
				horse.animation_player.play("Rocking")
				power = 1
				timer.start(horse.animation_player.current_animation_length * 5)
	pass

func reset():
	_state.velocity = Vector3.ZERO
	_player.velocity = Vector3.ZERO
	_state.move_direction = Vector3.ZERO
	_state.current_speed = Vector3.ZERO
	pass
