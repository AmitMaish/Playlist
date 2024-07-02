extends AudioStreamPlayer

var audioLoader = AudioLoader.new()

func LoadSong(path: String):
	# Thread saftey
	x.nextAudioAccess.lock()
	
	x.nextAudio = audioLoader.loadfile(path)

	#get song information
	x.nextSonglength = x.nextAudio.get_length()
	x.nextSamplerate = x.nextAudio.get_mix_rate()
	
	x.nextNumSamples = x.nextAudio.data.size()
	if x.nextAudio.stereo:
		x.nextNumSamples *= 0.5
	match x.nextAudio.format:
		0:
			pass
		1:
			x.nextNumSamples *= 0.5
	
	# Thread saftey
	x.nextAudioAccess.unlock()

func PlaySong():
	x.audioAccess.lock()
	if x.audio == null:
		return
	stream = x.audio
	volume_db = x.volume
	playing = true
	
	x.audioAccess.unlock()
