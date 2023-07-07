extends LevelStart

signal level_loaded

@export var number_of_coins := 400
@export var number_of_level_coins := 400

var coins_id_tracker := 0
var level_coins_id_tracker := 0

@onready var coins = $"Coin Meshes/Coins"

func _ready():
	$Player/StateMachine.level_loaded = true
	var children
	ensure_collectable_exists("COIN")
	ensure_collectable_exists("LEVEL COIN")
	emit_signal("level_loaded")
