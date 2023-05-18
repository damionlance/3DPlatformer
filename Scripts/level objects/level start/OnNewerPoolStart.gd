extends LevelStart

@onready var cannons = [$dynamicObjects/cannon1, $dynamicObjects/cannon2, $dynamicObjects/cannon3, $dynamicObjects/cannon4, $dynamicObjects/cannon5, $dynamicObjects/cannon6, $dynamicObjects/cannon7, $dynamicObjects/cannon8, $dynamicObjects/cannon9, $dynamicObjects/cannon10]
# TODO : Make this more efficient when addind new cannons ^

func _ready():
	
	ensure_collectable_exists("COIN")
	ensure_collectable_exists("POOL COIN")
	
	$Player/StateMachine.level_loaded = true
	if "Figment_BombsAway" in Global.WORLD_COLLECTIBLES:
		if Global.WORLD_COLLECTIBLES["Figment_BombsAway"] != true:
			for cannon in cannons:
				cannon.set_enabled(true)
		else:
			for cannon in cannons:
				cannon.set_enabled(false)
	else:
		for cannon in cannons:
			cannon.set_enabled(true)

func _process(_delta):
	if not is_level_preview:
		if $Player.global_position.y < -10:
			get_tree().reload_current_scene()
