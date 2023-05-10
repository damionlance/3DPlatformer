extends Collectable

const materials : Array = [
	preload("res://assets/materials/coin.tres"),
	preload("res://assets/materials/coinCollected.tres")
]

@onready var coinMesh = $Coin/Cylinder
@onready var coinAnimation = $Coin/AnimationTree
@onready var coin = $Coin
var playerBody

var speed = 0.0
var oneshot = true
var collectable = false

func _ready():
	if collected:
		change_material(1)
	else:
		change_material(0)

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
				playerBody.add_coin()
				queue_free()

func change_material(newMaterialIndex):
	coinMesh.set_surface_override_material(0, materials[newMaterialIndex])

func _on_coin_body_entered(body):
	if body.get_name() == "Player":
		playerBody = body
		collected = true
		Global.UPDATE_COLLECTIBLES(name, collected)
		_update_collectables(true)
