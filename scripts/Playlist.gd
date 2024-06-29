extends Node

func _ready():
	%FileDialogue.popup()

# The next song button TODO
func PlayNextSong():
	pass

# Choose the next song
func DetermineNextSong():
	# Let's be Thread Safe
	x.queueAccess.lock()
	x.RootAccess.lock()
	x.nextAudioAccess.lock()
	
	# Picking the song
	if x.queue.size() == 0:
		x.nextSong = x.RootDirectory.ChooseSong()
	else:
		x.nextSong = x.queue[0]
	
	# Thread saftey
	x.nextAudioAccess.unlock()
	x.RootAccess.unlock()
	x.queueAccess.unlock()

# Queue Management
func AddToQueue(song: Playable):
	x.queue.append(song)
	if x.queue.size() == 1:
		DetermineNextSong()

func RemoveFromQueue(index: int):
	# Remove item at the index
	x.queue.pop_at(index)
	
	# If the index is zero, we have changed the next song so we need to find a new song
	if index == 0:
		DetermineNextSong()


# Helper function that scans directories for playables
func OpenPlayableDirectory(dir: String):
	var directory = DirAccess.open(dir)
	print("Opened Directory: ", dir)
	
	var contents = Array()
	
	directory.list_dir_begin()
	var file = directory.get_next()
	
	while file != "":
		print("Found file: ", file)
		if file.ends_with(".wav") or file.ends_with(".mp3") or file.ends_with(".ogg") or directory.current_is_dir():
			var playable = Playable.new(dir + "/" + file)
			playable.name = file.split(".")[0]
			print("File Name: ", playable)
			if directory.current_is_dir():
				print("File is directory")
				playable.isDir = true
				print("Opening: ", dir + "/" + file)
				playable.children = OpenPlayableDirectory(dir + "/" + file)
				if playable.children.size() == 0:
					file = directory.get_next()
					continue
			contents.append(playable)
		file = directory.get_next()
	return contents



# ((********** Handle Inputs **********))
# Handle file dialogue
func _on_file_dialog_dir_selected(dir):
	x.RootAccess.lock()
	print("Playlist Selected")
	x.RootDirectory = Playable.new(dir)
	print("Assigned Root Directory")
	x.RootDirectory.name = "Root"
	print("Renamed Root Directory")
	x.RootDirectory.isDir = true
	x.RootDirectory.children = OpenPlayableDirectory(dir)
	print("Scanned Directory")
	
	var rootJSON : String
	
	var playlistJSON = FileAccess.open(x.RootDirectory.path + "/" + "playlist.json", FileAccess.READ)
	if playlistJSON == null:
		rootJSON = JSON.stringify(x.RootDirectory.Pack(), "\t", false, true)
	else:
		rootJSON = FileAccess.get_file_as_string(x.RootDirectory.path + "/" + "playlist.json")
		x.RootDirectory.UnPack(JSON.parse_string(rootJSON))
		playlistJSON.close()
	
	x.RootAccess.unlock()
	
	%Audio.FetchNextSong()
	%Audio.PlaySong()
	%UI.BuildMixer(x.RootDirectory)

# Handle closing notifications
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Closing")
		x.RootAccess.lock()
		var playlistJSON = FileAccess.open(x.RootDirectory.path + "/" + "playlist.json", FileAccess.WRITE)
		playlistJSON.store_string(JSON.stringify(x.RootDirectory.Pack(), "\t", false, true))
		x.RootAccess.unlock()
