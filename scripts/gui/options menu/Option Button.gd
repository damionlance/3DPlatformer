extends OptionButton


func _ready():
	for i in item_count:
		if get_item_text(i) == Global.settings[name]:
			selected = i
	connect("item_selected", _on_item_selected)

func _on_item_selected(index):
	$"../../../../../../".new_settings[name] = get_item_text(index)
