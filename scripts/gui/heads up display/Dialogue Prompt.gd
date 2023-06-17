@tool
extends RichTextLabel
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_parent().size = size + Vector2(10,10)

func add_new_text(new_text):
	text = "[center]" + new_text + "[/center]"
