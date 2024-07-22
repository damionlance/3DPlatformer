extends RichTextEffect
class_name BouncyLetters

var bbcode = "bouncy_letters"
var bounce_speed = 0
var char_tracker : Dictionary = {}
var char_speed : Dictionary = {} 

func _ready() -> void:
	char_tracker.clear()
	char_speed.clear()

func _process_custom_fx(char_fx : CharFXTransform) -> bool:
	var strength = char_fx.env.get("strength", 3)
	var speed: float = char_fx.env.get("speed", 30.0)
	var wait: int = char_fx.env.get("delay", 0.0)

	char_fx.visible = false

	if char_fx.elapsed_time * speed - wait >= char_fx.relative_index:
		char_fx.visible = true
	if not char_tracker.has(char_fx.relative_index) and char_fx.visible == true:
		char_tracker[char_fx.relative_index] = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * strength
		char_speed[char_fx.relative_index] = Vector2.ZERO
	elif char_tracker.has(char_fx.relative_index):
		char_speed[char_fx.relative_index] = char_speed[char_fx.relative_index].lerp(Vector2.ZERO - char_tracker[char_fx.relative_index] * 0.5, 0.05)
		char_tracker[char_fx.relative_index] += char_speed[char_fx.relative_index]
		char_fx.offset = char_tracker[char_fx.relative_index]
		char_fx.transform = char_fx.transform.scaled_local( Vector2.ONE + char_speed[char_fx.relative_index])
	
	return true
