extends AudioStreamPlayer

@export var intro : AudioStream
@export var song : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("finished", updateSong)
	stream = intro
	play()

func updateSong():
	stream = song
	play()
