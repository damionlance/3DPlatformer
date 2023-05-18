extends Collectable

var materials

@onready var coinMesh = $Coin/Cylinder
@onready var coinAnimation = $Coin/AnimationTree
@onready var coin = $Coin

var collectable_name : String

var playerBody

var speed = 0.0
var oneshot = true
var collectable = false

func _ready():
	collectable_name = name.rstrip('1234567890')
	materials = "res://assets/materials/" + collectable_name.to_lower() + ".tres"
	add_to_group("coins")
	if collected:
		change_material(1)

func _process(delta):
	if collected:
		if oneshot:
			coinAnimation["parameters/jumpFire/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			coinAnimation["parameters/pickupBlend/blend_amount"] = 1
			oneshot = false
		elif not collectable and not coinAnimation["parameters/jumpFire/active"]:
			collectable = true
			global_position = coin.global_position
		if collectable:
			if speed < 20:
				speed += 1.0
			var direction = (playerBody.global_position + Vector3.UP) - self.global_position
			self.position += (direction.normalized() * speed * delta)
			if direction.length() < 1 and collectable:
				_update_collectables(true)
				playerBody.add_coin(collectable_name.to_upper())
				queue_free()

func change_material(newMaterialIndex):
	coinMesh.get_surface_override_material(0).albedo_color.a = .25

func _on_coin_body_entered(body):
	if body.get_name() == "Player":
		collected = true
		playerBody = body
		emit_signal("collectable_touched", collectable_name.to_lower())
	
