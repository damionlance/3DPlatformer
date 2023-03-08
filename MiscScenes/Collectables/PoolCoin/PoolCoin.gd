extends Collectable


const materials : Array = [
	preload("res://MiscScenes/Collectables/PoolCoin/PoolCoin.tres"),
	preload("res://MiscScenes/Collectables/PoolCoin/PoolCoinCollected.tres")
]

@onready var coinMesh = $Coin/Cylinder

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if collected:
		change_material(1)
	else:
		change_material(0)

func change_material(newMaterialIndex):
	coinMesh.set_surface_override_material(0, materials[newMaterialIndex])

func _on_body_entered(body):
	if body.get_name() == "Player":
		collected = true
		Global.UPDATE_COLLECTIBLES(name, collected)
		body.add_levelcoin(0)
