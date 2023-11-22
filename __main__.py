import wave
import sys
import os
import math
import time

import pyaudio

from rich.progress import Progress

# import keyboard

BufferSize = 1024

if len(sys.argv) < 2:
	print(f'Plays a wave file. Usage: {sys.argv[0]} filename.wav')
	sys.exit(-1)

# os.system('clear')

with wave.open(sys.argv[1], 'rb') as wf:
	# Define callback for playback (1)
	with Progress(auto_refresh=True) as progress:
		task1 = progress.add_task('[red]' + sys.argv[1], total=wf.getnframes())
		def callback(in_data, frame_count, time_info, status):
			data = wf.readframes(frame_count)
			progress.update(task1, advance=frame_count)
			# If len(data) is less than requested frame_count, PyAudio automatically
			# assumes the stream is finished, and the stream stops.
			return (data, pyaudio.paContinue)
		# keyboard.on_press_key("p", pause)

   		# Instantiate PyAudio and initialize PortAudio system resources (2)
		p = pyaudio.PyAudio()

			# Open stream using callback (3)
		stream = p.open(format=p.get_format_from_width(wf.getsampwidth()),
						channels=wf.getnchannels(),
						rate=wf.getframerate(),
						output=True,
						frames_per_buffer=BufferSize,
						stream_callback=callback)

		# Wait for stream to finish (4)
		while stream.is_active():
			time.sleep(0.1)

		# Close the stream (5)
		stream.close()

		# Release PortAudio system resources (6)
		p.terminate()