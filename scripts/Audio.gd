extends AudioStreamPlayer

var audioLoader = AudioLoader.new()
@export var fileDialogue: FileDialog
@export var timeSince: Label
@export var timeline: HSlider
@export var timeRemaining: Label
@export var label : Label
@export var interface: Control

@export var pauseIcon: Texture
@export var playIcon: Texture

var timelineTween
var countingTween

var volume

var playingSongLength
var playingNumSamples
var playingSamplerate
var playingFormat

func LoadSong(path: String):
	x.audio = audioLoader.loadfile(path)

	#get song information
	x.songLength = x.audio.get_length()
	x.samplerate = x.audio.get_mix_rate()
	
	x.numSamples = x.audio.data.size()
	if x.audio.stereo:
		x.numSamples *= 0.5
	match x.audio.format:
		0:
			pass
		1:
			x.numSamples *= 0.5

func PlaySong():
	if x.audio == null:
		return
	stream = x.audio
	volume_db = volume
	playingSongLength = x.songLength
	playingNumSamples = x.numSamples
	playingSamplerate = x.samplerate
	playing = true
	
	TweenTransport()
	label.text = x.nextSong.name
	FetchNextSong()

func FetchNextSong():
	var nextItem = x.queue.pop_front()

	if nextItem == null:
		x.queued = false
		x.nextSong = x.RootDirectory.ChooseSong()
		#print(nextSong, " chosen")
		interface.UpdateUpNext(x.nextSong)
		
		interface.removeNextSong.hide()
	else:
		x.queued = true
		x.nextSong = nextItem.ChooseSong()
		#interface.RemoveFromQueue(0)
		interface.RemoveFromQueue(0)
		
		interface.UpdateUpNext(nextItem)
		
		interface.removeNextSong.show()
	volume = x.nextSong.volume
	LoadSong(x.nextSong.path)

func TweenTransport():
	KillTweens()
	CreateTweens()
	InitTweening()
	FireTweens()

func KillTweens():
	if timelineTween != null:
		timelineTween.kill()
	if countingTween != null:
		countingTween.kill()

func CreateTweens():
	timelineTween = get_tree().create_tween()
	countingTween = get_tree().create_tween()
	countingTween.set_parallel(true)
	countingTween.set_loops()

func InitTweening():
	timeline.max_value = playingNumSamples
	timeline.value = 0
	timeSince.time = 0
	timeRemaining.time = 0
	timeSince.DisplayTime(0)
	timeRemaining.DisplayTime(playingSongLength)

func FireTweens():
	timelineTween.tween_property(timeline, "value", playingNumSamples, (playingSongLength - get_playback_position()))
	countingTween.tween_callback(timeSince.DisplayTime.bind(1)).set_delay(1)
	countingTween.tween_callback(timeRemaining.DisplayTime.bind(-1)).set_delay(1)


func _on_skip_button_pressed():
	PlaySong()

func _on_play_pause_toggled(toggled_on):
	if toggled_on:
		%Play_Pause.icon = playIcon
		stream_paused = true
		KillTweens()
	else:
		stream_paused = false
		CreateTweens()
		FireTweens()
		%Play_Pause.icon = pauseIcon

func _on_timeline_drag_started():
	KillTweens()

func _on_timeline_drag_ended(value_changed):
	var timeElapsed = timeline.value  / playingSamplerate
	var timeLeft = playingSongLength - timeElapsed
	#print(timeElapsed," ", playingSongLength," ", timeLeft)
	seek(timeElapsed)
	
	timeSince.time = 0
	timeRemaining.time = 0
	timeSince.DisplayTime(floor(timeElapsed))
	timeRemaining.DisplayTime(floor(timeLeft))
	CreateTweens()
	FireTweens()

func AddToQueue(cue: Playable):
	x.queue.append(cue)
	#print("Player queue status:", queued)
	if !x.queued:
		FetchNextSong()
	#print(queue)
	return x.queue.size()

func RemoveFromQueue(index: int):
	if index == -1:
		FetchNextSong()
		return
	#print(queue)
	x.queue.pop_at(index)
