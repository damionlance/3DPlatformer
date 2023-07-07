extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in item_count:
		if get_item_text(i) == Global.settings["Window Mode"]:
			selected = i
