extends PanelContainer

var selectedChannel: Playable

func SelectChannel(song: Playable):
	selectedChannel = song
	%ChannelName.text = song.name
	%ChannelName.editable = true
	%VolumeSlider.set_value_no_signal(song.volume)


func _on_add_to_queue_pressed():
	%UI.AddToQueue(selectedChannel)


func _on_volume_slider_value_changed(value):
	selectedChannel.volume = value
