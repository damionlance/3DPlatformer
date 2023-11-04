extends Figment

var fragmentsCollected = 0
var collectable = false
@onready var fig = $Figment

# Called when the node enters the scene tree for the first time.
func _ready():
	fig.body_entered.connect(_on_figment_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fragmentsCollected > 3:
		collectable = true
	if !collectable:
		collected = false
		self.visible = false
	else:
		self.visible = true
		
	if collected:
		change_material(1)
	else:
		change_material(0)


func _on_fig_frag_body_entered(body):
	if body.get_name() == "Player":
		fragmentsCollected += 1
