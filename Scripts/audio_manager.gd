extends Node

@onready var bg_layer_1 = $BgLayer1
@onready var bg_layer_2 = $BgLayer2
@onready var bg_layer_3 = $BgLayer3

# Call this function from anywhere to play a sound effect
func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0):
	# Create a new player dynamically so multiple sounds can overlap
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.volume_db = volume_db
	instance.pitch_scale = pitch_scale
	
	add_child(instance)
	instance.play()
	
	# Clean up the player when the sound finishes
	await instance.finished
	instance.queue_free()

# Call this to play background music
func play_music(stream: AudioStream):
	if bg_layer_1.stream == stream and bg_layer_1.playing:
		return # Don't restart if it's already playing
	
	bg_layer_1.stream = stream
	bg_layer_1.play()

func stop_music():
	bg_layer_1.stop()

func play_dungeon_ambiance(stream1: AudioStream, stream2: AudioStream, stream3: AudioStream, volume1: float = 0.0, volume2: float = 0.0, volume3: float = 0.0):
	# Setup Layer 1
	if bg_layer_1.stream != stream1:
		bg_layer_1.stream = stream1
		bg_layer_1.volume_db = volume1
		bg_layer_1.play()
	
	# Setup Layer 2
	if bg_layer_2.stream != stream2:
		bg_layer_2.stream = stream2
		bg_layer_2.volume_db = volume2
		bg_layer_2.play()
		
	if bg_layer_3.stream != stream3:
		bg_layer_3.stream = stream3
		bg_layer_3.volume_db = volume3
		bg_layer_3.play()

func stop_all_music():
	bg_layer_1.stop()
	bg_layer_2.stop()
	bg_layer_3.stop()
