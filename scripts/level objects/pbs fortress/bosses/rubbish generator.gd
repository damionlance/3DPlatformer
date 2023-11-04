extends Node

var timer

var number_of_active_rubbish := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.add_to_group("rubbish piles")
		child.visible = false
	timer = Timer.new()
	add_child(timer)
	timer.start(5)
	timer.connect("timeout", rubbish_check)

func rubbish_check():
	var rubbish = randi()%6
	if get_child(rubbish).visible == true:
		reset_timer()
		return
	get_child(rubbish).visible = true

func reset_timer():
	timer.start(5)
