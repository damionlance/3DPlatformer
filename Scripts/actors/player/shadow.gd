extends RayCast3D

@onready var player = get_parent()
@onready var shadow = $PlayerShadow

func _ready():
	set_as_top_level(true)

func _process(delta):
	
	if is_colliding():
		shadow.global_position = get_collision_point()
		shadow.scale = Vector3.ONE * (1-((shadow.global_position - player.global_position).length() / target_position.length()))
	global_position = player.global_position
	global_position.y += .1
	
