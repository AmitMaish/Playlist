import wave
import sys
import os
import math
import time

import pyaudio

from rich.progress import Progress

from pynput import keyboard

paused = False
running = True

def on_press(key):
	global running
	global paused
	match key:
		case keyboard.Key.esc:
			running = False
			paused = True
			return
		case _:
			pass
	match key.char:
		case 'p':
			paused = not paused
		case _:
			pass
def on_release(key):
	pass

listener = keyboard.Listener(
    on_press=on_press,
    on_release=on_release)
listener.start()

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
			if paused:
				data = b'\00'
				return (data, pyaudio.paComplete)
			data = wf.readframes(frame_count)
			progress.update(task1, advance=frame_count)
			# If len(data) is less than requested frame_count, PyAudio automatically
			# assumes the stream is finished, and the stream stops.
			return (data, pyaudio.paContinue)

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
		while running:
			while stream.is_active():
				time.sleep(0.1)
			while paused and running:
				time.sleep(0.1)
			stream = p.open(format=p.get_format_from_width(wf.getsampwidth()),
						channels=wf.getnchannels(),
						rate=wf.getframerate(),
						output=True,
						frames_per_buffer=BufferSize,
						stream_callback=callback)

		# Close the stream (5)
		stream.close()

		# Release PortAudio system resources (6)
		p.terminate()