extends Control

var dialogue: NodePath

var cursor_default = load("res://ArtAssets/Cursor_Sepia.png")
var cursor_POI = load("res://ArtAssets/Cursor_Brown.png")

var visible_clues: Array = []
var clues_on_screen: Array = []

@onready var player_horse: CharacterBody2D = $BackgroundLayers/Parallax2D2/PlayerHorse


# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
	"Scent0" : false,
	"Scent1" : false,
	"Sound0" : false,
	"SoftSpot" : false,
	"StallionHallucination" : false,
	"Hoofprints" : false,
}

# this means it has been clicked
var clues_interacted = {
	"Scent0" : false,
	"Scent1" : false,
	"Sound0" : false,
	"SoftSpot" : false,
	"StallionHallucination" : false,
	"Hoofprints" : false,
}


func _ready():
	Input.set_custom_mouse_cursor(cursor_default)
	Input.set_custom_mouse_cursor(cursor_POI, Input.CURSOR_POINTING_HAND)
	Global.player_start_position = Vector2(400, 750)
	Global.sense_mode_changed.connect(sense_change)
	Global.clues_interacted["GetUp"] = true
	Global.current_sense = Global.senses.SEE
	_on_see_button_pressed()
	
	
func _on_scent_0_pressed() -> void:
	if Global.current_sense == Global.senses.SMELL:
		if Global.player_POI_position != Global.POIs.SCENT_0:
			Global.visit_clue.emit(Vector2(%Scent0.position.x - 50, %Scent0.position.y + 0))
			await Global.arrived
			Global.player_POI_position = Global.POIs.SCENT_0
		else:
			dialogue = "res://Dialogue/28_E3_start.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			clues_interacted["Scent0"] = true
			clues_discovered["Scent1"] = true
			await DialogueManager.dialogue_ended
			%Scent0.remove_from_group("smell")
			#%Scent1.add_to_group("smell")
			_on_smell_button_pressed()


func _on_scent_1_pressed() -> void:
	if Global.current_sense == Global.senses.SMELL:
		if Global.player_POI_position != Global.POIs.SCENT_1:
			Global.visit_clue.emit(Vector2(%Scent1.position.x - 50, %Scent1.position.y + 0))
			await Global.arrived
			Global.player_POI_position = Global.POIs.SCENT_1
		else:
			dialogue = "res://Dialogue/47_happy_memory.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			clues_interacted["Scent1"] = true
			clues_discovered["Sound0"] = true
			await DialogueManager.dialogue_ended
			%Sound0.add_to_group("hear")
			%Scent1.remove_from_group("smell")
			_on_smell_button_pressed()


func _on_sound_0_pressed() -> void:
	if Global.current_sense == Global.senses.HEAR:
		if Global.player_POI_position != Global.POIs.SOUND_0:
			Global.visit_clue.emit(Vector2(%Sound0.position.x - 50, %Sound0.position.y + 0))
			await Global.arrived
			Global.player_POI_position = Global.POIs.SOUND_0
		else:
			dialogue = "res://Dialogue/48_happy_memory.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			clues_interacted["Sound0"] = true
			await DialogueManager.dialogue_ended
			%Sound0.remove_from_group("hear")
			_on_hear_button_pressed()
			for n in 100:
				$Camera2D.position.x += 8
				await get_tree().create_timer(0.00000001).timeout
			Global.visit_clue.emit(Vector2(player_horse.position.x +500, player_horse.position.y + 0))
			for n in 150:
				$Camera2D.position.x += 8
				await get_tree().create_timer(0.00000001).timeout
			#print($Camera2D.position.x, " player: ", player_horse.position.x)
			dialogue = "res://Dialogue/29_need_a_break.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			clues_on_screen = get_tree().get_nodes_in_group("on_screen")
			for n in clues_on_screen:
				n.remove_from_group("on_screen")
			%SoftSpot.add_to_group("on_screen")
			%SoftSpot.add_to_group("see")
			%SoftSpot.disabled = false
			%StallionHallucination.add_to_group("on_screen")
			$SmokeParticles3.emitting = true


func _on_soft_spot_pressed() -> void:
	if Global.player_POI_position != Global.POIs.SOFTSPOT:
		Global.visit_clue.emit(Vector2(%SoftSpot.position.x +700, %SoftSpot.position.y + 250))
		await Global.arrived
		Global.player_POI_position = Global.POIs.SOFTSPOT
	else:
		if not clues_interacted["SoftSpot"]:
			Global.clues_interacted["GetUp"] = false
			$MusicAudio.stream = load("res://Music/Don't Give Up.mp3")
			$MusicAudio.play()
			# lie down animation
			clues_interacted["SoftSpot"] = true
			await get_tree().create_timer(1).timeout
			stallion_hallucination()
	

func stallion_hallucination() -> void:
	%StallionHallucination.show()
	if not clues_interacted["StallionHallucination"]:
		%HallucinationAnimationPlayer.play("hallucination")
		await %HallucinationAnimationPlayer.animation_finished
		dialogue = "res://Dialogue/30_soft_spot_memory.tres"
		DialogueManager.start_dialogue(dialogue, 0)
		await DialogueManager.dialogue_ended
		clues_interacted["StallionHallucination"] = true
		Global.clues_interacted["GetUp"] = true
		$MusicAudio.stream = load("res://Music/E3 Seeing - Before Resting.mp3")
		$MusicAudio.play()
		for n in 50:
			$Camera2D.position.x += 8
			await get_tree().create_timer(0.00000001).timeout
		Global.visit_clue.emit(Vector2(player_horse.position.x + 1500, player_horse.position.y + 0))
		$SmokeParticles.emitting = false
		for n in 300:
			$Camera2D.position.x += 8
			await get_tree().create_timer(0.00000001).timeout
		clues_on_screen = get_tree().get_nodes_in_group("on_screen")
		for n in clues_on_screen:
			n.remove_from_group("on_screen")
		%Hoofprints.add_to_group("on_screen")
		%Hoofprints.add_to_group("see")
		clues_discovered["Hoofprints"] = true


func _on_hoofprints_pressed() -> void:
	if Global.player_POI_position != Global.POIs.HOOFPRINTS:
		Global.visit_clue.emit(Vector2(%Hoofprints.position.x + 50, %Hoofprints.position.y + 20))
		await Global.arrived
		Global.player_POI_position = Global.POIs.HOOFPRINTS
	else:
		if Global.current_sense == Global.senses.HEAR:
			dialogue = "res://Dialogue/13_can't_hear.tres"
			DialogueManager.start_dialogue(dialogue, 1)
		elif Global.current_sense == Global.senses.SMELL:
			dialogue = "res://Dialogue/14_can't_smell.tres"
			DialogueManager.start_dialogue(dialogue, 1)
		else:
			dialogue = "res://Dialogue/31_hoofprints.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			await DialogueManager.dialogue_ended
			clues_interacted["Hoofprints"] = true
			Global.visit_clue.emit(Vector2(player_horse.position.x + 1000, player_horse.position.y + 0))
			await get_tree().create_timer(1.5).timeout
			switch_scene()


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
	$BackgroundLayers/Parallax2D2/Middle.modulate = Color(0.5, 0.5, 0.5)
	$Parallax2D3/Foreground.self_modulate = Color(0.5, 0.5, 0.5)
	%SoftSpot.modulate = Color(0.5, 0.5, 0.5)
	%Hoofprints.self_modulate = Color(0.5, 0.5, 0.5)
	

func lighten_surroundings():
	$BackgroundLayers/Parallax2D/Sky.self_modulate = Color(1.0, 1.0, 1.0)
	$BackgroundLayers/Parallax2D2/Middle.modulate = Color(1.0, 1.0, 1.0)
	$Parallax2D3/Foreground.self_modulate = Color(1.0, 1.0, 1.0)
	%SoftSpot.modulate = Color(1.0, 1.0, 1.0)
	%Hoofprints.self_modulate = Color(1.0, 1.0, 1.0)
	

func muffle_music():
	$MusicAudio.volume_db = -7.153
	$MusicAudio.pitch_scale = 0.81
	
	
func normalize_music():
	$MusicAudio.volume_db = 0.0
	$MusicAudio.pitch_scale = 1.0


func show_scents():
	%Scent0.visible = true
	%Particles0.emitting = true
	if clues_discovered["Scent1"] and not clues_interacted["Scent1"]:
		%Scent1.visible = true
		%Particles1.emitting = true


func hide_scents():
	%Scent0.visible = false
	%Particles0.emitting = false
	%Scent1.visible = false
	%Particles1.emitting = false


func show_sounds():
	if clues_discovered["Sound0"] and not clues_interacted["Sound0"]:
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
	var sense_clues = ["Scent0", "Scent1", "Sound0"]
	for n in clues_on_screen:
		if clues_discovered[n.name]:
			n.show()
			# the sense clues in this episode are meant to disappear after use
			if sense_clues.has(n.name):
				if not clues_interacted[n.name]:
					n.show()
				else:
					n.hide()


func switch_scene():
	$SwitchScreen.show()
	var A = 0.0
	for n in 10:
		A += 0.1
		$SwitchScreen/Panel.self_modulate = Color(0.0, 0.0, 0.0, A)
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://environment_4.tscn")
