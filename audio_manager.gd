extends Node

var active_music_stream: AudioStreamPlayer
var new_music_stream: AudioStreamPlayer

var special: bool = false


@export var music: Node
@export var sfx: Node
@export var va: Node


func play_music(audio_name: String, from_position: float):
	new_music_stream = music.get_node(audio_name)
	if music.get_node(audio_name) == null:
		return
	#print("New: ", new_music_stream)
	#print("Previous: ", active_music_stream)
	#new_music_stream.volume_db = linear_to_db(1.0)
	new_music_stream.play(from_position)
	#if from_position == null:
	if active_music_stream:
		await fade_out_and_in_music()
	else:
		await fade_in_music()
	active_music_stream = new_music_stream
	new_music_stream = null
	
	
	#if $MusicAudio.stream.get_length() < from_position:
		#$MusicAudio.play()
		##print("played from start")
	#else:
		#$MusicAudio.play(from_position)
		##print("played from current position: ", from_position)
	
func fade_out_music():
	#if Global.music_volume > 0:
		#for n in 10:
			#active_music_stream.volume_db = linear_to_db(-n)
			#await get_tree().create_timer(0.01).timeout
	active_music_stream.stop()
	active_music_stream = null
	print("old music is dead")
	

func fade_in_music():
	#if Global.music_volume > 0:
		#print(new_music_stream.volume_db)
		#for n in 10:
			#print(new_music_stream.volume_db)
			#new_music_stream.volume_db = linear_to_db(n/2)
			#await get_tree().create_timer(0.01).timeout
	pass
	
	
func fade_out_and_in_music():
	#if Global.music_volume > 0:
		#for n in 10:
			#active_music_stream.volume_db -= linear_to_db(-n)
			#new_music_stream.volume_db = linear_to_db(n/2)
			#await get_tree().create_timer(0.01).timeout
		active_music_stream.stop()
		active_music_stream = null
		print("old music is dead, long live new music")
