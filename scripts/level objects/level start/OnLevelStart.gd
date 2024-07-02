extends Node3D

class_name LevelStart

signal level_loaded

@export var number_of_coins := 400
@export var number_of_level_coins := 400

var coins_id_tracker := 0
var level_coins_id_tracker := 0

@onready var coins = $"Coins"
var is_level_preview = false

var collectibles : Dictionary

@onready var obj_root := find_child(name)

var cinematic_cameras

# Called when the node enters the scene tree for the first time.
func _ready():
	ensure_collectable_exists("COIN")
	ensure_collectable_exists("LEVEL COIN")
	$"Player/CanvasLayer/HUD/MarginContainer/counters/level coin".compare_against = obj_root.level_coins
	for i in 200:
		coins.multimesh.set_instance_transform(i,Transform3D(Basis(), Vector3.ZERO))
	emit_signal("level_loaded")

func ensure_collectable_exists(collectable_name):
	if not Global.WORLD_COLLECTIBLES.has(collectable_name):
		Global.WORLD_COLLECTIBLES[collectable_name] = 0
