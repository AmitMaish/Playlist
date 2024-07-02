class_name Channel

extends PanelContainer

var playable	:	Playable
var playlist	:	Node

func Setup(song : Playable):
	playable = song
	%"Mute Button".button_pressed = song.mute
	%"Solo Button".button_pressed = song.solo
	%"Channel Name".text = song.name
	%Weight.value = song.weight

func _on_v_slider_drag_started():
	%WeightMargin.visible = true
	print(playable)

func _on_v_slider_drag_ended(value_changed):
	%WeightMargin.visible = false
	playable.weight = %Weight.value

func _on_v_slider_value_changed(value):
	%WeightMargin/Weight.text = "%.2f" % value

func _on_mute_button_toggled(toggled_on):
	playable.mute = toggled_on

func _on_solo_button_toggled(toggled_on):
	playable.solo = toggled_on


func _on_channel_name_text_submitted(new_text):
	%"Channel Name".hide()
	%"Channel Name".show()
	playable.name = new_text

func _on_mouse_entered():
	%"Queue Button".show()
	%"Fullscreen Button".show()

func _on_mouse_exited():
	if %"Queue Button" != null: 
		%"Queue Button".hide()
		%"Fullscreen Button".hide()

func _on_add_to_queue_pressed():
	print("Add to queue pressed")
	playlist.AddToQueue(playable)

func _on_fullscreen_pressed():
	playlist.DisplayDirectory(playable)

func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			%"Queue Button".hide()
			%"Fullscreen Button".hide()
