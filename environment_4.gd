extends Control

var dialogue: NodePath

var cursor_default = load("res://ArtAssets/Cursor_Sepia.png")
var cursor_POI = load("res://ArtAssets/Cursor_Brown.png")

var visible_clues: Array = []
var clues_on_screen: Array = []

@onready var player_horse: CharacterBody2D = $BackgroundLayers/Parallax2D2/PlayerHorse



# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
	"Destroy0" : false,
	"Destroy1" : false,
	"Destroy2" : false,
	"Destroy3" : false,
	"Destroy4" : false,
	"Sound0" : false,
	"Spring" : false,
	"Rage" : false,
}

# this means it has been clicked
var clues_interacted = {
	"Destroy0" : false,
	"Destroy1" : false,
	"Destroy2" : false,
	"Destroy3" : false,
	"Destroy4" : false,
	"Sound0" : false,
	"Spring" : false,
	"Rage" : false,
}



func _ready():
	Input.set_custom_mouse_cursor(cursor_default)
	Input.set_custom_mouse_cursor(cursor_POI, Input.CURSOR_POINTING_HAND)
	Global.player_start_position = Vector2(400, 750)
	Global.sense_mode_changed.connect(sense_change)
	Global.current_sense = Global.senses.SEE
	_on_see_button_pressed()
	Global.clues_interacted["GetUp"] = true
	await get_tree().create_timer(1).timeout
	dialogue = "res://Dialogue/32_E4_start.tres"
	DialogueManager.start_dialogue(dialogue, 0)
	await DialogueManager.dialogue_ended
	_provisorium()
	

func _provisorium():
	#await get_tree().create_timer(4).timeout
	for n in 520:
			$Camera2D.position.x += 8
			if $Camera2D.position.x * 0.7 >= player_horse.position.x:
				Global.visit_clue.emit(Vector2($Camera2D.position.x * 0.7, player_horse.position.y + 0))
			await get_tree().create_timer(0.00000001).timeout
	if Global.current_state.name == "Trot":
		await Global.arrived
	dialogue = "res://Dialogue/33_finding_him.tres"
	DialogueManager.start_dialogue(dialogue, 0)
	await DialogueManager.dialogue_ended
	for n in 320:
			$Camera2D.position.x += 2
			if $Camera2D.position.x * 0.7 >= player_horse.position.x:
				Global.visit_clue.emit(Vector2($Camera2D.position.x * 0.7, player_horse.position.y + 0))
			await get_tree().create_timer(0.00000001).timeout
	#$BackgroundLayers/Parallax2D2/PlayerHorse/Camera2D.enabled = true
	#$Camera2D.enabled = false
	var A = 1.0
	for n in 10:
		A -= 0.1
		$Parallax2D4.modulate = Color(1.0, 1.0, 1.0, A)
		await get_tree().create_timer(0.1).timeout



func _on_sound_0_pressed() -> void:
	if Global.current_sense == Global.senses.HEAR:
		if Global.player_POI_position != Global.POIs.SOUND_0:
			Global.visit_clue.emit(Vector2(%Sound0.position.x - 50, %Sound0.position.y + 0))
			await Global.arrived
			Global.player_POI_position = Global.POIs.SOUND_0
		else:
			dialogue = "res://Dialogue/00_dialogue_missing.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			clues_interacted["Sound0"] = true
			await DialogueManager.dialogue_ended
			for n in 150:
				$Camera2D.position.x += 8
				await get_tree().create_timer(0.00000001).timeout
			Global.visit_clue.emit(Vector2(3420, 500))
			for n in 400:
				$Camera2D.position.x += 8
				await get_tree().create_timer(0.00000001).timeout
			#await Global.arrived
			clues_on_screen = get_tree().get_nodes_in_group("on_screen")
			for n in clues_on_screen:
				n.remove_from_group("on_screen")
			%Spring.add_to_group("on_screen")
			%Destroy0.add_to_group("on_screen")
			%Destroy1.add_to_group("on_screen")
			%Destroy2.add_to_group("on_screen")
			%Destroy3.add_to_group("on_screen")
			%Destroy4.add_to_group("on_screen")


func _on_spring_pressed() -> void:
	if Global.player_POI_position != Global.POIs.SPRING:
		%BentTree.z_index = 0
		if not clues_interacted["Spring"]:
			Global.visit_clue.emit(Vector2(%Spring.position.x +100, %Spring.position.y + 10))
		else:
			if clues_interacted["Rage"]:
				Global.visit_clue.emit(Vector2(%Spring.position.x +150, %Spring.position.y + 0))
		await Global.arrived
		Global.player_POI_position = Global.POIs.SPRING
	else:
		if not clues_interacted["Spring"]:
			clues_interacted["Spring"] = true
			dialogue = "res://Dialogue/46_finding_him_2.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			await DialogueManager.dialogue_ended
			cutscene_dead()
		else:
			if clues_interacted["Rage"]:
				Global.clues_interacted["GetUp"] = false
				await get_tree().create_timer(2).timeout
				dialogue = "res://Dialogue/39_i_love_him.tres"
				DialogueManager.start_dialogue(dialogue, 0)
				await DialogueManager.dialogue_ended
				cutscene_grief()


func cutscene_dead():
	$StillImageLayer.show()
	var A = 0.0
	for n in 10:
		A += 0.1
		$StillImageLayer/Panel.self_modulate = Color(0.0, 0.0, 0.0, A)
		$StillImageLayer/Panel/StillImage.self_modulate = Color(1.0, 1.0, 1.0, A)
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(4).timeout
	$StillImageLayer.hide()
	clues_discovered["Destroy0"] = true
	Global.speed = 400
	%RedParticles0.emitting = true
	$RageLayer.visible = true
	$RageLayer/AnimationPlayer.play("rage")
	


func _on_destroy_0_pressed() -> void:
	_on_destroy(Global.POIs.DESTROY0, %Destroy0, %RedParticles0, "res://Dialogue/34_rage0.tres", %Destroy1)
	
func _on_destroy_1_pressed() -> void:
	_on_destroy(Global.POIs.DESTROY1, %Destroy1, %RedParticles1, "res://Dialogue/35_rage1.tres", %Destroy3)

func _on_destroy_2_pressed() -> void:
	_on_destroy(Global.POIs.DESTROY2, %Destroy2, %RedParticles2, "res://Dialogue/38_rage4.tres", null)

func _on_destroy_3_pressed() -> void:
	_on_destroy(Global.POIs.DESTROY3, %Destroy3, %RedParticles3, "res://Dialogue/36_rage2.tres", %Destroy4)

func _on_destroy_4_pressed() -> void:
	_on_destroy(Global.POIs.DESTROY4, %Destroy4, %RedParticles4, "res://Dialogue/37_rage3.tres", %Destroy2)


func _on_destroy(pos, object, particle, line, next_object):
	if object.get_child(0).emitting:
		%BentTree.z_index = 4
		if Global.player_POI_position != pos:
			Global.visit_clue.emit(Vector2(object.position.x +30, object.position.y + 260))
			await Global.arrived
			Global.player_POI_position = pos
		else:
			if not clues_interacted[object.name]:
				particle.emitting = false
				if "rock" in object.texture_normal.resource_path:
					$SFXAudio.stream = load("res://SFX/freesound_community-rock-destroy-6409.mp3")
					$SFXAudio.play()
					object.texture_normal = load("res://ArtAssets/rock_broken_.png")
				if "tree" in object.texture_normal.resource_path:
					$SFXAudio.stream = load("res://SFX/Kick.ogg")
					$SFXAudio.play()
					object.texture_normal = load("res://ArtAssets/tree_broken.png")
				#if $SFXAudio.playing:
					#await $SFXAudio.finished
				await get_tree().create_timer(1).timeout
				dialogue = line
				DialogueManager.start_dialogue(dialogue, 0)
				await DialogueManager.dialogue_ended
				clues_interacted[object.name] = true
				if next_object != null:
					clues_discovered[next_object.name] = true
					next_object.get_child(0).emitting = true
				else:
					clues_interacted["Rage"] = true
					Global.speed = 200
					$RageLayer/AnimationPlayer.stop()
					$RageLayer.hide()
					%BentTree.z_index = 0

	
func cutscene_grief():
	$StillImageLayer.show()
	%StillAnimationPlayer.play("show_slideshow")
	next_slide("res://ArtAssets/still1.png", "res://Dialogue/40_ending1.tres")
	await %StillAnimationPlayer.animation_finished
	next_slide("res://ArtAssets/still3.png", "res://Dialogue/41_ending2.tres")
	await %StillAnimationPlayer.animation_finished
	next_slide("res://ArtAssets/still5.png", "res://Dialogue/42_ending3.tres")
	await %StillAnimationPlayer.animation_finished
	next_slide("res://ArtAssets/still4.png", "res://Dialogue/43_ending4.tres")
	await %StillAnimationPlayer.animation_finished
	next_slide("res://ArtAssets/still6.png", "res://Dialogue/44_ending5.tres")
	await %StillAnimationPlayer.animation_finished
	next_slide(null, "res://Dialogue/45_ending6.tres")
	await %StillAnimationPlayer.animation_finished
	$StillImageLayer/Panel/Credits.show()
	var A = 0.0
	for n in 10:
		A += 0.1
		$StillImageLayer/Panel/Credits.self_modulate = Color(1.0, 1.0, 1.0, A)
	
	
func next_slide(path, line):
	if path != null:
		%StillImage.texture = load(path)
	else:
		%StillImage.texture = null
	%StillAnimationPlayer.play("new_slide")
	dialogue = line
	DialogueManager.start_dialogue(dialogue, 0)
	await get_tree().create_timer(2).timeout
	%StillAnimationPlayer.pause()
	if DialogueManager.is_active:
		await DialogueManager.dialogue_ended
	%StillAnimationPlayer.play()
	
	
	
	
	
	
func sense_change():
	if Global.current_sense == Global.senses.SEE:
		_on_see_button_pressed()
	if Global.current_sense == Global.senses.HEAR:
		_on_hear_button_pressed()
	if Global.current_sense == Global.senses.SMELL:
		_on_smell_button_pressed()


func _on_see_button_pressed() -> void:
	hide_sounds()
	hide_scents()
	lighten_surroundings()
	normalize_music()
	visible_clues = get_tree().get_nodes_in_group("see")
	update_sense()


func _on_hear_button_pressed() -> void:
	hide_scents()
	darken_surroundings()
	muffle_music()
	show_sounds()
	visible_clues = get_tree().get_nodes_in_group("hear")
	update_sense()


func _on_smell_button_pressed() -> void:
	hide_sounds()
	normalize_music()
	darken_surroundings()
	show_scents()
	visible_clues = get_tree().get_nodes_in_group("smell")
	update_sense()
	
	
func darken_surroundings():
	$BackgroundLayers/Parallax2D/Sky.self_modulate = Color(0.5, 0.5, 0.5)
	$BackgroundLayers/Parallax2D2/Middle.self_modulate = Color(0.5, 0.5, 0.5)
	$Parallax2D3/Foreground.self_modulate = Color(0.5, 0.5, 0.5)


func lighten_surroundings():
	$BackgroundLayers/Parallax2D/Sky.self_modulate = Color(1.0, 1.0, 1.0)
	$BackgroundLayers/Parallax2D2/Middle.self_modulate = Color(1.0, 1.0, 1.0)
	$Parallax2D3/Foreground.self_modulate = Color(1.0, 1.0, 1.0)


func muffle_music():
	$MusicAudio.volume_db = -7.153
	$MusicAudio.pitch_scale = 0.81
	
	
func normalize_music():
	$MusicAudio.volume_db = 0.0
	$MusicAudio.pitch_scale = 1.0


func show_scents():
	#%Scent0.visible = true
	#%Particles0.emitting = true
	#if clues_discovered["Scent1"]:
		#%Scent1.visible = true
		#%Particles1.emitting = true
	pass


func hide_scents():
	pass


func show_sounds():
	if clues_discovered["Sound0"]:
		%Sound0.visible = true
		%Particles2.emitting = true


func hide_sounds():
	%Sound0.visible = false
	%Particles2.emitting = false

# updates showing all currently discovered clues
func update_sense():
	clues_on_screen = get_tree().get_nodes_in_group("on_screen")
	# sets all clues (currently on screen) of the current sense to discovered
	for n in clues_on_screen:
		if visible_clues.has(n):
				clues_discovered[n.name] = true
	# shows all discovered clues currently on screen
	for n in clues_on_screen:
		if clues_discovered[n.name]:
			n.show()


func switch_scene():
	$SwitchScreen.show()
	var A = 0.0
	for n in 10:
		A += 0.1
		$SwitchScreen/Panel.self_modulate = Color(0.0, 0.0, 0.0, A)
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://environment_4.tscn")
