extends TextEdit

func _input(event):
	match event.as_text():
		"Enter":
			hide()
			show()
