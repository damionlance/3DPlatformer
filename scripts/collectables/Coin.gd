extends Collectable

@onready var root = get_tree().get_current_scene()
@onready var coin = $Coin

@export var bounce_height : float = 0.0
var multimesh

var collectable_name : String

var playerBody

var speed = 0.0
var oneshot = true
var collectable = false
var previously_collected = false
var touched = false
var hide = false
var instance_id : int

var tween

var spin_tween
var bob_tween
var new_pos
var bounce_position
var rotation_speed = (randf()/8.0)+.1

var special_coin = false

func _ready():
	$AnimationPlayer.seek(randf()/2.0)
	if root is Control:
		queue_free()
		return
	await root.level_loaded
	
	if Global.WORLD_COLLECTIBLES.has(name):
		collected = Global.WORLD_COLLECTIBLES[name]
	else:
		Global.WORLD_COLLECTIBLES[name] = collected
	if "LevelCoin" in name:
		collectable_name = "level coin"
	else:
		collectable_name = "coin"
	add_to_group("coins")
	basis = Basis().rotated(Vector3.LEFT, deg_to_rad(90.0))
	root.coins_id_tracker += 1
	multimesh = root.coins.multimesh
	instance_id = root.coins_id_tracker
	if collected:
		if "LevelCoin" in name:
			multimesh.set_instance_color(instance_id, Color.STEEL_BLUE)
		else:
			multimesh.set_instance_color(instance_id, Color.DARK_GOLDENROD)
		previously_collected = true
	else:
		if "LevelCoin" in name:
			multimesh.set_instance_color(instance_id, Color.TURQUOISE)
		else:
			multimesh.set_instance_color(instance_id, Color.GOLD)
			
	
	new_pos = global_position
	multimesh.set_instance_transform(instance_id, Transform3D(basis, new_pos))

func _process(delta):
	if hide:
		return
	basis = basis.rotated(Vector3.UP, rotation_speed)
	if touched:
		if collected:
			hide_coin()
			return
		if speed < 20:
			speed += 1.0
		var direction = (playerBody.global_position + Vector3.UP) - self.global_position
		self.position += (direction.normalized() * speed * delta)
		multimesh.set_instance_transform(instance_id, Transform3D(basis, self.global_position - root.coins.global_position))
		if collectable:
			for body in $Coin.get_overlapping_bodies():
				if body.name == "Player":
					collected = true
					if not previously_collected:
						_update_collectables(true)
						playerBody.add_coin(collectable_name.to_upper())
					hide_coin()
	else:
		bounce_position = new_pos + Vector3(0, bounce_height,0)
		multimesh.set_instance_transform(abs(instance_id), Transform3D(basis, bounce_position))

func _on_coin_body_entered(body):
	if body.get_name() == "Player" and not touched:
		$AudioStreamPlayer.pitch_scale = randf() + 1.0
		$AudioStreamPlayer.play(0)
		process_mode = Node.PROCESS_MODE_PAUSABLE
		playerBody = body
		if not collected:
			emit_signal("collectable_touched", collectable_name.to_lower())
		tween = create_tween()
		tween.tween_property(self, "position", position + Vector3(0,3,0), .75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_callback(_allow_collect)
		touched = true

func _allow_collect():
	collectable = true

func hide_coin():
	hide = true
	tween.stop()
	multimesh.set_instance_transform(instance_id, Transform3D(basis, -Vector3.UP*1000))
