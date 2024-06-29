extends Label

var time = 0

func DisplayTime(change: int):
	time += change
	var seconds = floor(time)
	var minutes = floor(seconds/60)
	var hours = floor(minutes/60)
	seconds -= minutes*60
	minutes -= hours*60
	
	if hours > 0:
		text = "%02d:%02d:%02d" % [hours, minutes, seconds]
	text = "%02d:%02d" % [minutes, seconds]
