class_name Channel

extends PanelContainer

var playable: Playable
var UI: UI

func Setup(song: Playable):
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


func _on_mouse_exited():
	%"Queue Button".hide()

func _on_add_to_queue_pressed():
	UI.AddToQueue(playable)
