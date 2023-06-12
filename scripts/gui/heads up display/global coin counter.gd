extends Control

var number_of_coins = 0
var horizontal_tween
var bounce_tween
var on_screen = false

@onready var label = $"MarginContainer/VSplitContainer/coin counter"
@export var collectable_name : String

var starting_position

var timer

func _ready():
	starting_position = $MarginContainer.position
	if Global.WORLD_COLLECTIBLES.has(collectable_name.to_upper()):
		number_of_coins = Global.WORLD_COLLECTIBLES[collectable_name.to_upper()]
	label.text = "x " + str(number_of_coins)
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(_leave_screen)

func _increase_coins():
	number_of_coins += 1
	label.text = "x " + str(number_of_coins)
	bounce_tween = create_tween()
	bounce_tween.tween_property($MarginContainer, "position", $MarginContainer.position + Vector2(0,10), .1).set_trans(Tween.TRANS_ELASTIC)
	bounce_tween.tween_property($MarginContainer, "position", Vector2($MarginContainer.position.x, starting_position.y), .1).set_trans(Tween.TRANS_ELASTIC)

func _enter_screen():
	timer.wait_time = 3
	if not on_screen:
		horizontal_tween = create_tween()
		timer.start()
		on_screen = true
		horizontal_tween.tween_property($MarginContainer, "position", starting_position - Vector2(450,0), .5).set_trans(Tween.TRANS_BOUNCE)

func _leave_screen():
	on_screen = false
	horizontal_tween = create_tween()
	horizontal_tween.tween_property($MarginContainer, "position", starting_position, .5)
