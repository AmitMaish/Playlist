class_name UI
extends Control

@export var removeNextSong: Control
@export var nextSongLabel: RichTextLabel

var queueDisplay = Array()
var queued : bool = false

# Preloaded Scenes
var ChannelGroup
var Channel
var cuedItem

# Tweens for the timeline
var timelineTween
var countingTween

# In _ready() we preload scenes so we can instantiate them at a later time
func _ready():
	ChannelGroup = preload("res://scenes/channel_group.tscn")
	Channel = preload("res://scenes/channel.tscn")
	cuedItem = preload("res://scenes/cued_song.tscn")

# Function for populating the mixer with channels representing the different playables
func BuildMixer(node : Node, dir : Playable):
	for child in dir.children:
		#print(child)
		if child.isDir:
			var channelInstance = ChannelGroup.instantiate()
			channelInstance.Setup(child)
			channelInstance.playlist = $".."
			node.add_child(channelInstance)
			BuildMixer(channelInstance.find_child("Children"), child)
			channelInstance.focus_entered.connect(%SelectedChannel.SelectChannel.bind(child))
			continue
		var channelInstance = Channel.instantiate()
		channelInstance.Setup(child)
		channelInstance.playlist = $".."
		node.add_child(channelInstance)
		channelInstance.focus_entered.connect(%SelectedChannel.SelectChannel.bind(child))

# Function for updating the queue display
func UpdateQueueDisplay():
	# Thread saftey
	x.queueAccess.lock()
	x.nextAudioAccess.lock()
	
	UpdateUpNext(x.nextSong)
	
	# Ensure the queue display is as long as the queue
	var cuesNeeded = x.queue.size() - queueDisplay.size() - 1 # we subtract 1 to account for the NextSong display
	print("Queue updating, we need ", cuesNeeded, " cues")
	
	# Match lengths
	if cuesNeeded > 0:
		for i in range(cuesNeeded):
			var newCue = cuedItem.instantiate()
			newCue.UI = %UI
			%QueueList.add_child(newCue)
			queueDisplay.append(newCue)
	elif cuesNeeded < 0:
		for i in range(abs(cuesNeeded)):
			var cue = queueDisplay.pop_back()
			print("Removing cue: ", cue)
			if cue != null:
				cue.queue_free()
				print("Cue removed")
	
	var index = 1
	for cue in queueDisplay:
		#cue.%SongTitle.text = x.queue[index]
		cue.Setup(x.queue[index], index) 
		index += 1
	
	x.nextAudioAccess.unlock()
	x.queueAccess.unlock()

func UpdateUpNext(song: Playable):
	nextSongLabel.text = song.name
	if x.queue.size() > 0:
		%UpNext.text = "Next in Queue:"
		%Queued.show()
	else:
		%UpNext.text = "Up Next:"
		%Queued.hide()


# Handle tweening the timeline
func TweenTimeline(startSample : int, totalSamples : int, samplerate : int):
	# Ensure we're starting with new tweens
	KillTweens()
	
	# Create the new tweens
	timelineTween = get_tree().create_tween()
	countingTween = get_tree().create_tween()
	countingTween.set_parallel(true)
	countingTween.set_loops()
	
	# Initialize the tweening values
	%Timeline.max_value = totalSamples
	%TimeElapsed.time = 0
	%TimeRemaining.time = 0
	%TimeElapsed.DisplayTime(startSample / samplerate)
	%TimeRemaining.DisplayTime((totalSamples - startSample) / samplerate)
	
	# Start the tweening
	timelineTween.tween_property(%Timeline, "value", totalSamples, (totalSamples - startSample) / samplerate).from(startSample)
	countingTween.tween_callback(%TimeElapsed.DisplayTime.bind(1)).set_delay(1)
	countingTween.tween_callback(%TimeRemaining.DisplayTime.bind(-1)).set_delay(1)

func KillTweens():
	if timelineTween != null:
		timelineTween.kill()
	if countingTween != null:
		countingTween.kill()


# Handle UI Inputs
func _on_open_inspector_pressed():
	%OpenInspector.hide()
	%InspectorContainer.show()

func _on_close_inspector_pressed():
	%OpenInspector.show()
	%InspectorContainer.hide()


func _on_next_song_mouse_entered():
	%RemoveRemoveNextFromQueue.show()

func _on_next_song_mouse_exited():
	%RemoveRemoveNextFromQueue.hide()

# Handle inputs from cues
func OnRemoveFromQueuePressed(index : int):
	print("Remove ", index, " from queue pressed")
	$"..".RemoveFromQueue(index)
