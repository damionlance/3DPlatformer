extends RigidBody3D

var current_level := 0

var collider
var visual

var breaks_on_ground := true
@onready var timer := Timer.new()
# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if global_position.y < -100:
		queue_free()

func _ready():
	add_to_group("holdable")
	add_to_group("heavy")
	collider = $"CollisionShape3D"
	visual = $"CSGSphere3D"
	increase_size()

func start_expiring():
	print("Hello")
	timer.one_shot = true
	add_child(timer)
	timer.start(15)
	timer.connect("timeout", destroy)

func destroy():
	queue_free()

func increase_size():
	current_level += 1
	visual.radius = 0.25 * current_level
	collider.shape.radius = 0.25 * current_level


func _on_body_entered(body):
	if body.is_in_group("scared of rubbish") and body.state._current_state.state_name != "Damaged":
		body.state.HP -= current_level
		body.state.update_state("Damaged")
		destroy()
	elif breaks_on_ground:
		if body.name != "Player":
			destroy()


func _on_sleeping_state_changed():
	if sleeping and not breaks_on_ground:
		start_expiring()
