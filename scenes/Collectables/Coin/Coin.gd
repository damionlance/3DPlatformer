extends Collectable

const materials : Array = [
	preload("res://scenes/Collectables/Coin/coin.tres"),
	preload("res://scenes/Collectables/Coin/coinCollected.tres")
]

@onready var coinMesh = $Coin/Cylinder

func _process(delta):
	if collected:
		change_material(1)
	else:
		change_material(0)

func change_material(newMaterialIndex):
	coinMesh.set_surface_override_material(0, materials[newMaterialIndex])

func _on_coin_body_entered(body):
	if body.get_name() == "Player":
		collected = true
		Global.UPDATE_COLLECTIBLES(name, collected)
		body.add_coin()
		_update_collectables(true)
		queue_free()
