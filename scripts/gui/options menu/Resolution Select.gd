extends OptionButton

func _ready():
	for i in item_count:
		if get_item_text(i) == Global.settings["Resolution"]:
			selected = i
