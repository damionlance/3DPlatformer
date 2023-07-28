extends AudioStreamPlayer

@export var intro : AudioStream
@export var song : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("finished", updateSong)
	stream = intro
	volume_db = -5
	play()

func updateSong():
	stream = song
	volume_db = -10
	play()
