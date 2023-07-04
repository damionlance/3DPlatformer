extends LevelStart


func _ready():
	$Player/StateMachine.level_loaded = true
	var children
	ensure_collectable_exists("COIN")
	ensure_collectable_exists("POOL COIN")
