extends HBoxContainer

signal RemoveTag

func Setup(tagName : String):
	$"Tag Name".text = tagName

func _on_mouse_entered():
	$"Remove Tag".show()


func _on_mouse_exited():
	$"Remove Tag".hide()


func _on_remove_tag_pressed():
	RemoveTag.emit()
