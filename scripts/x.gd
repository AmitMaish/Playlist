extends Node

var RootDirectory:	Playable
var RootAccess	:	Mutex = Mutex.new()

var song		:	Playable
var audio		:	AudioStream
var audioAccess	:	Mutex = Mutex.new()

#Song Info
var songLength
var numSamples
var samplerate

var nextSong	:	Playable
var nextAudio	:	AudioStream
var nextAudioAccess: Mutex = Mutex.new()

var queue		:	Array = Array()
var queued		:	bool = false
var queueAccess	:	Mutex = Mutex.new()

var volume		:	float = 0#db
