extends Collectable

@onready var coinMesh = $Coin/Cylinder
@onready var coinAnimation = $Coin/AnimationTree
@onready var coin = $Coin

var collectable_name : String

var playerBody

var speed = 0.0
var oneshot = true
var collectable = false
var previously_collected = false
var touched = false

var special_coin = false

func _ready():
	if Global.WORLD_COLLECTIBLES.has(name):
		collected = Global.WORLD_COLLECTIBLES[name]
	else:
		Global.WORLD_COLLECTIBLES[name] = collected
	if special_coin:
		collectable_name = "level coin"
	else:
		collectable_name = "coin"
	add_to_group("coins")
	if collected:
		coinMesh.set_surface_override_material(0, load("res://assets/materials/" + collectable_name.to_lower() + "_collected.tres"))
		previously_collected = true
	else:
		coinMesh.set_surface_override_material(0, load("res://assets/materials/" + collectable_name.to_lower() + ".tres"))

func _process(delta):
	if touched:
		if speed < 20:
			speed += 1.0
		var direction = (playerBody.global_position + Vector3.UP) - self.global_position
		self.position += (direction.normalized() * speed * delta)

func _on_coin_body_entered(body):
	if body.get_name() == "Player" and not touched:
		playerBody = body
		emit_signal("collectable_touched", collectable_name.to_lower())
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector3(0,3,0), .75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		touched = true
	elif body.get_name() == "Player" and touched:
		if not previously_collected:
			_update_collectables(true)
			playerBody.add_coin(collectable_name.to_upper())
		queue_free()
