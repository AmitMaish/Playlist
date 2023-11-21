import wave
import sys
import math
import time

import pyaudio

from rich.progress import Progress

CHUNK = 1024

if len(sys.argv) < 2:
	print(f'Plays a wave file. Usage: {sys.argv[0]} filename.wav')
	sys.exit(-1)

with wave.open(sys.argv[1], 'rb') as wf:
	# Instantiate PyAudio and initialize PortAudio system resources (1)
	p = pyaudio.PyAudio()

	# Open stream (2)
	stream = p.open(format=p.get_format_from_width(wf.getsampwidth()),
					channels=wf.getnchannels(),
					rate=wf.getframerate(),
					output=True)
	
	# Make a progress bar for the track
	with Progress() as progress:
		task1 = progress.add_task('[red]' + sys.argv[1], total=wf.getnframes())

		# Play samples from the wave file (3)
		while len(data := wf.readframes(CHUNK)):  # Requires Python 3.8+ for :=
			stream.write(data)
			progress.update(task1, advance=CHUNK)


	# Close stream (4)
	stream.close()

	# Release PortAudio system resources (5)
	p.terminate()