extends Node

func _ready():
	%FileDialog.popup()

# The next song button
func PlayNextSong():
	x.SongEquallsNextSong()
	
	%Audio.PlaySong()
	
	# After selecting the next song we need to determine the song after it.
	# First we update the queue
	x.queueAccess.lock()
	if x.queue.front() != null:
		x.queue.pop_front()
	x.queueAccess.unlock()
	
	# Then we determine the next song and load it into memory
	DetermineNextSong()
	%Audio.LoadSong(x.nextSong.path)
	
	# Finally we update the UI
	%SongPlaying.text = x.song.name
	%UI.UpdateQueueDisplay()
	%UI.TweenTimeline(0, x.numSamples, x.samplerate)

# Choose the next song
func DetermineNextSong():
	# Let's be Thread Safe
	x.queueAccess.lock()
	x.RootAccess.lock()
	x.nextAudioAccess.lock()
	
	x.volume = 0
	
	# Picking the song
	x.nextSong = x.queue.front()
	if x.nextSong == null:
		x.nextSong = x.RootDirectory.ChooseSong()
	elif x.nextSong.isDir:
		x.nextSong = x.nextSong.ChooseSong()
	
	# Thread saftey
	x.nextAudioAccess.unlock()
	x.RootAccess.unlock()
	x.queueAccess.unlock()

# Queue Management
func AddToQueue(song: Playable):
	print("Adding ", song, " to queue.")
	x.queue.append(song)
	
	# If the queue only has one song, we've changed the next song.
	if x.queue.size() == 1:
		print("Queue change caused next song to change")
		DetermineNextSong()
	
	%UI.UpdateQueueDisplay()

func RemoveFromQueue(index: int):
	# Thread saftey
	x.queueAccess.lock()
	
	# Remove item at the index
	print("Remove ", index, " from queue recieved")
	x.queue.pop_at(index)
	
	print("Queue now is: ", x.queue)
	
	# Thread saftey
	x.queueAccess.unlock()
	
	# If the index is zero, we have changed the next song so we need to find a new song
	if index == 0:
		DetermineNextSong()
	
	%UI.UpdateQueueDisplay()


# Helper function that scans directories for playables
func OpenPlayableDirectory(dir: String):
	var directory = DirAccess.open(dir)
	#print("Opened Directory: ", dir)
	
	var contents = Array()
	
	directory.list_dir_begin()
	var file = directory.get_next()
	
	while file != "":
		#print("Found file: ", file)
		if file.ends_with(".wav") or file.ends_with(".mp3") or file.ends_with(".ogg") or directory.current_is_dir():
			var playable = Playable.new(dir + "/" + file)
			playable.name = file.split(".")[0]
			#print("File Name: ", playable)
			if directory.current_is_dir():
				#print("File is directory")
				playable.isDir = true
				#print("Opening: ", dir + "/" + file)
				playable.children = OpenPlayableDirectory(dir + "/" + file)
				if playable.children.size() == 0:
					file = directory.get_next()
					continue
			contents.append(playable)
		file = directory.get_next()
	
	return contents


func _on_audio_finished():
	pass # Replace with function body.



# ((********** Handle Inputs **********))
# Handle file dialogue
func _on_file_dialog_dir_selected(dir):
	x.RootAccess.lock()
	#print("Playlist Selected")
	x.RootDirectory = Playable.new(dir)
	#print("Assigned Root Directory")
	x.RootDirectory.name = "Root"
	#print("Renamed Root Directory")
	x.RootDirectory.isDir = true
	x.RootDirectory.children = OpenPlayableDirectory(dir)
	#print("Scanned Directory")
	
	var rootJSON : String
	
	var playlistJSON = FileAccess.open(x.RootDirectory.path + "/" + "playlist.json", FileAccess.READ)
	if playlistJSON == null:
		rootJSON = JSON.stringify(x.RootDirectory.Pack(), "\t", false, true)
	else:
		rootJSON = FileAccess.get_file_as_string(x.RootDirectory.path + "/" + "playlist.json")
		x.RootDirectory.UnPack(JSON.parse_string(rootJSON))
		playlistJSON.close()
	
	x.currentDir = x.RootDirectory
	x.RootAccess.unlock()
	
	x.nextSong = x.currentDir.ChooseSong()
	%Audio.LoadSong(x.nextSong.path)
	x.SongEquallsNextSong()
	PlayNextSong()
	DisplayDirectory(x.currentDir)

# Handle skip button
func _on_skip_button_pressed():
	PlayNextSong()

# Handle transport
func _on_play_pause_toggled(toggled_on):
	if toggled_on:
		%Play_Pause.icon = x.playIcon
		%Audio.stream_paused = true
		%UI.KillTweens()
	else:
		%Audio.stream_paused = false
		%UI.TweenTimeline(%Timeline.value, x.numSamples, x.samplerate)
		%Play_Pause.icon = x.pauseIcon

func _on_timeline_drag_started():
	%UI.KillTweens()

func _on_timeline_drag_ended(value_changed):
	var timeElapsed = %Timeline.value  / x.samplerate
	#print(timeElapsed," ", playingSongLength," ", timeLeft)
	%Audio.seek(timeElapsed)
	
	%UI.TweenTimeline(%Timeline.value, x.numSamples, x.samplerate)

func DisplayDirectory(group : Playable):
	for child in %Mixer.get_children():
		child.queue_free()
	x.currentDir = group
	%UI.BuildMixer(%Mixer, group)
	
	%Header.Setup(group)

# Handle closing notifications
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Closing")
		x.RootAccess.lock()
		var playlistJSON = FileAccess.open(x.RootDirectory.path + "/" + "playlist.json", FileAccess.WRITE)
		playlistJSON.store_string(JSON.stringify(x.RootDirectory.Pack(), "\t", false, true))
		x.RootAccess.unlock()
