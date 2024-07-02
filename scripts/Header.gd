extends PanelContainer

var currentDir : Playable

func Setup(group : Playable):
	currentDir = group
	%CurrentDirectoryLabel.text = group.name

func _on_mouse_entered():
	%"Return to Root".show()

func _on_mouse_exited():
	%"Return to Root".hide()

func _on_focus_entered():
	%SelectedChannel.SelectChannel(currentDir)


func _on_return_to_root_pressed():
	x. currentDir = x.RootDirectory
	$"../../../../../../../../..".DisplayDirectory(x.RootDirectory)
