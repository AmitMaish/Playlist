extends TextEdit

func _input(event):
	if has_focus():
		if event is InputEventKey and event.is_pressed():
			if event.keycode == KEY_ENTER:
				hide()
				show()
				%SelectedChannel.AddTag(text)
				clear()

