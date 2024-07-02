extends PanelContainer

var UI: Control
var index : int

func Setup(song : Playable, _index : int):
	%SongTitle.text = song.name
	index = _index

func _on_mouse_entered():
	$MarginContainer/HBoxContainer/RemoveFromQueue.show()

func _on_mouse_exited():
	$MarginContainer/HBoxContainer/RemoveFromQueue.hide()


func _on_remove_from_queue_pressed():
	print(UI)
	UI.OnRemoveFromQueuePressed(index)
