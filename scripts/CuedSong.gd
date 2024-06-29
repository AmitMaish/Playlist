extends PanelContainer

var queueIndex
var UI: Control

func Setup(song: Playable, index: int):
	queueIndex = index
	%SongTitle.text = song.name

func _on_mouse_entered():
	$MarginContainer/HBoxContainer/RemoveFromQueue.show()

func _on_mouse_exited():
	$MarginContainer/HBoxContainer/RemoveFromQueue.hide()


func _on_remove_from_queue_pressed():
	print(UI)
	UI.RemoveFromQueuePressed(queueIndex)
