extends LevelStart


func _ready():
	$Player/StateMachine.level_loaded = true
	var children
