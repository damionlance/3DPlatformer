extends Collectable

const materials : Array = [
	preload("res://MiscScenes/Collectables/FigFrag/FigFrag.tres"),
	preload("res://MiscScenes/Collectables/FigFrag/FigFragCollected.tres")
]

@onready var figmentMesh = $FigFrag/mesh

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if collected:
		queue_free()
	else:
		change_material(0)

func change_material(newMaterialIndex):
	figmentMesh.set_surface_override_material(0, materials[newMaterialIndex])

func _on_fig_frag_body_entered(body):
	if body.get_name() == "Player":
		collected = true
		Global.UPDATE_COLLECTIBLES(name, collected)
