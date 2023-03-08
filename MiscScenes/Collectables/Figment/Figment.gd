extends Collectable

const materials : Array = [
	preload("res://MiscScenes/Collectables/Figment/Figment.tres"),
	preload("res://MiscScenes/Collectables/Figment/FigmentCollected.tres")
]

@onready var figmentMesh = $Figment/mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if collected:
		change_material(1)
	else:
		change_material(0)

func change_material(newMaterialIndex):
	figmentMesh.set_surface_override_material(0, materials[newMaterialIndex])

func _on_figment_body_entered(body):
	if body.get_name() == "Player":
		collected = true
		Global.UPDATE_COLLECTIBLES(name, collected)
