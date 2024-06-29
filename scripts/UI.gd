class_name UI
extends Control

# hello
var root
@export var audioPlayer: AudioStreamPlayer
@export var removeNextSong: Control
@export var nextSongLabel: RichTextLabel
var upNext
var queueSeperator
var queueList
@export var UI: Control

var mixer
var ChannelInspector

var queue = Array()
var queued : bool = false

var ChannelGroup
var Channel
var cuedItem


func _ready():
	mixer = %Mixer
	ChannelInspector = %SelectedChannel
	upNext = %UpNext
	queueSeperator = %QueueSeperator
	queueList = %QueueList
	ChannelGroup = preload("res://channel_group.tscn")
	Channel = preload("res://channel.tscn")
	cuedItem = preload("res://cued_song.tscn")

func BuildMixer(rootDirectory: Playable):
	root = rootDirectory
	BuildDirectory(mixer, root)

func BuildDirectory(node: Node, dir: Playable):
	for child in dir.children:
		#print(child)
		if child.isDir:
			var channelInstance = ChannelGroup.instantiate()
			channelInstance.Setup(child)
			channelInstance.UI = self
			node.add_child(channelInstance)
			BuildDirectory(channelInstance.find_child("Children"), child)
			channelInstance.focus_entered.connect(ChannelInspector.SelectChannel.bind(child))
			continue
		var channelInstance = Channel.instantiate()
		channelInstance.Setup(child)
		channelInstance.UI = self
		node.add_child(channelInstance)
		channelInstance.focus_entered.connect(ChannelInspector.SelectChannel.bind(child))

func _on_open_inspector_pressed():
	%OpenInspector.hide()
	%InspectorContainer.show()

func _on_close_inspector_pressed():
	%OpenInspector.show()
	%InspectorContainer.hide()

func AddToQueue(song: Playable):
	#print("UI Queue status: ", queued)
	if queued == false:
		UpdateUpNext(song)
		upNext.text = "Next in Queue:"
		queued = true
		audioPlayer.AddToQueue(song)
		return
	queueSeperator.show()
	var newItem = cuedItem.instantiate()
	newItem.Setup(song, audioPlayer.AddToQueue(song) - 1)
	newItem.UI = %UI
	queue.append(newItem)
	queueList.add_child(newItem)

func RemoveFromQueue(index: int):
	#print("UI Queue status: ", queued)
	#print("UI Queue size: ", queue.size())
	if (index == -1):
		if (queue.size() == 0):
			queued = false
			upNext.text = "Up Next:"
			queueSeperator.hide()
		return
	if (queue.size() == 0):
		queueSeperator.hide()
	var song = queue.pop_at(index)
	if song == null:
		return
	print("Removing ", song.name, " from Queue")
	song.queue_free()
	var i = 0
	for item in queue:
		item.queueIndex = i
		i += 1

func RemoveFromQueuePressed(index: int):
	RemoveFromQueue(index)
	audioPlayer.RemoveFromQueue(index)

func UpdateUpNext(song: Playable):
	#print(%NextSongLabel.text)
	nextSongLabel.text = song.name

func _on_next_song_mouse_entered():
	%RemoveFromQueue.show()

func _on_next_song_mouse_exited():
	%RemoveFromQueue.hide()

func _on_remove_from_queue_pressed():
	RemoveFromQueuePressed(-1)
