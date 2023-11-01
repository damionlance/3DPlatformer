extends LevelStart

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
	$"Player/HUD/MarginContainer/counters/level coin".compare_against = obj_root.level_coins
	for i in 200:
		coins.multimesh.set_instance_transform(i,Transform3D(Basis(), Vector3.ZERO))
	emit_signal("level_loaded")
