extends PanelContainer

var selectedChannel: Playable
var tag : PackedScene

func _ready():
	tag = preload("res://scenes/tag.tscn")

func SelectChannel(song: Playable):
	selectedChannel = song
	%ChannelName.text = song.name
	%AlbumName.text = song.album
	%ArtistName.text = song.artist
	%ChannelName.editable = true
	%AlbumName.editable = true
	%ArtistName.editable = true
	%TagEnter.editable = true
	%VolumeSlider.set_value_no_signal(song.volume)
	
	DisplayTags()

func DisplayTags():
	for child in %Tags.get_children():
		child.queue_free()
	
	for item in selectedChannel.tags:
		var newTag = tag.instantiate()
		newTag.Setup(item)
		newTag.RemoveTag.connect(RemoveTag.bind(item))
		%Tags.add_child(newTag)

func RemoveTag(tag : String):
	selectedChannel.tags.erase(tag)
	DisplayTags()
	
	x.knownTags[tag] -= 1
	if x.knownTags[tag] == 0:
		x.knownTags.erase(tag)

func _on_add_to_queue_pressed():
	$"../../../../../../../../..".AddToQueue(selectedChannel)

func _on_volume_slider_value_changed(value):
	selectedChannel.volume = value

func _on_transport_focus_entered():
	# Thread saftey
	x.audioAccess.lock()
	
	SelectChannel(x.song)
	
	x.audioAccess.unlock()


func _on_channel_name_text_changed():
	print(%ChannelName.text)
	selectedChannel.name = %ChannelName.text
	print(selectedChannel.name)


func _on_album_name_text_changed():
	print(%AlbumName.text)
	selectedChannel.album = %AlbumName.text


func _on_artist_name_text_changed():
	selectedChannel.artist = %ArtistName.text


func AddTag(newTag: String):
	if selectedChannel.tags.has(newTag):
		return
	selectedChannel.tags.append(newTag)
	selectedChannel.tags.sort()
	
	DisplayTags()
	
	print("Chanel has tags: ", selectedChannel.tags)
	
	if x.knownTags.has(newTag):
		x.knownTags[newTag] += 1
		return
	x.knownTags[newTag] = 1
