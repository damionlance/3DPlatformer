extends Node

var stars = {"Atop the Mountain": false, "Down the Lazy River": false, "Pipes!": false}
var time_start

var WORLD_COLLECTIBLES : Dictionary
var has_saved := false

var save_semaphore
var mutex
var thread
var exit_thread

var callable
# Called when the node enters the scene tree for the first time.
func _ready():
	mutex = Mutex.new()
	save_semaphore = Semaphore.new()
	exit_thread = false
	
	thread = Thread.new()
	callable = Callable(self, "_save_data")
	thread.start(callable)
	if FileAccess.file_exists("user://temp_save.res"):
		var data = FileAccess.open("user://temp_save.res", FileAccess.READ)
		var json = JSON.new()
		var parse_result = json.parse(data.get_line())
		if parse_result == OK:
			WORLD_COLLECTIBLES = json.data

func UPDATE_COLLECTIBLES(name, value):
	mutex.lock()
	WORLD_COLLECTIBLES[name] = value
	mutex.unlock()
	save_semaphore.post()
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _save_data():
	
	while true:
		save_semaphore.wait()
		
		mutex.lock()
		var should_exit = exit_thread
		mutex.unlock()
		
		if should_exit:
			break
		
		mutex.lock()
		
		var save_game = FileAccess.open("user://temp_save.res", FileAccess.WRITE)
		var json = JSON.stringify(WORLD_COLLECTIBLES)
		save_game.store_line(json)
		
		mutex.unlock()

func _exit_tree():
	mutex.lock()
	exit_thread = true
	mutex.unlock()
	save_semaphore.post()
	
	thread.wait_to_finish()
