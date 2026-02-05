extends Node

@onready var music_player = $MusicPlayer

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
	if music_player.stream == stream and music_player.playing:
		return # Don't restart if it's already playing
	
	music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()
