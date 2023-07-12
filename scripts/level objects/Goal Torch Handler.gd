extends Node3D

signal completed

var complete = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if complete:
		completed.emit()
	if Global.WORLD_COLLECTIBLES.has("ButtonStand1") and Global.WORLD_COLLECTIBLES["ButtonStand1"] == true:
		$"Fire 1".visible = true
		if Global.WORLD_COLLECTIBLES.has("ButtonStand2") and Global.WORLD_COLLECTIBLES["ButtonStand2"] == true:
			$"Fire 2".visible = true
			if Global.WORLD_COLLECTIBLES.has("ButtonStand4") and Global.WORLD_COLLECTIBLES["ButtonStand4"] == true:
				$"Fire 3".visible = true
				complete = true
				
	
	
