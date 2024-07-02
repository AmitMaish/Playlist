extends Node

var RootDirectory:	Playable
var currentDir	:	Playable
var RootAccess	:	Mutex = Mutex.new()

var song		:	Playable
var audio		:	AudioStream
var audioAccess	:	Mutex = Mutex.new()

#Song Info
var songlength
var numSamples
var samplerate

var nextSonglength
var nextNumSamples
var nextSamplerate

var nextSong	:	Playable
var nextAudio	:	AudioStream
var nextAudioAccess: Mutex = Mutex.new()

var queue		:	Array = Array()
var queued		:	bool = false
var queueAccess	:	Mutex = Mutex.new()

var volume		:	float = 0#db


# Assets
var pauseIcon	:	Texture
var playIcon	:	Texture

func _enter_tree():
	pauseIcon = preload("res://icons/pause.svg")
	playIcon = preload("res://icons/play_arrow.svg")

func SongEquallsNextSong():
	# Thread saftey
	audioAccess.lock()
	nextAudioAccess.lock()
	
	song = nextSong
	audio = nextAudio
	songlength = nextSonglength
	numSamples = nextNumSamples
	samplerate = nextSamplerate
	
	nextAudioAccess.unlock()
	audioAccess.unlock()
