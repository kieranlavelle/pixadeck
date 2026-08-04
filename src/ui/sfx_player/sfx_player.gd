extends Node

## Spawns a global, non-spatial sound (like UI clicks or background music)
func play_sound(stream: AudioStream, volume: float = 0.0, pitch: float = 1.0, bus: StringName = &"sfx") -> AudioStreamPlayer:
	if not stream:
		return null
		
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume
	player.pitch_scale = pitch
	player.bus = bus
	
	add_child(player)
	player.play()
	
	# Automatically delete the node when the sound finishes
	player.finished.connect(player.queue_free)
	
	return player
