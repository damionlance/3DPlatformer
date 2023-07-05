extends LevelStart

signal level_loaded

func _ready():
	$Player/StateMachine.level_loaded = true
	var children
	ensure_collectable_exists("COIN")
	ensure_collectable_exists("LEVEL COIN")
	emit_signal("level_loaded")
