extends Control

var dialogue: DialogueData

var visible_clues: Array = []
var clues_on_screen: Array = []


# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
	"Scent0" : false,
	"Scent1" : false,
	"Sound0" : false,
	"SoftSpot" : false,
	"StallionHallucination" : false,
	"Hoofprints" : false,
	
	"Tree0" : false,
	"ManeHair" : false,
	"Bucket" : false,
	"Stream" : false,
	"Tree1" : false,
	"Tree2" : false,
	"Tree3" : false,
	"Tree4" : false,
	"StallionScent" : false,
	"Smoldering" : false,
}

# this means it has been clicked
var clues_interacted = {
	"Scent0" : false,
	"Scent1" : false,
	"Sound0" : false,
	"SoftSpot" : false,
	"StallionHallucination" : false,
	"Hoofprints" : false,
	
	"Tree0" : false,
	"ManeHair" : false,
	"Bucket" : false,
	"Stream" : false,
	"Tree1" : false,
	"Tree2" : false,
	"Tree3" : false,
	"Tree4" : false,
	"StallionScent" : false,
	"Smoldering" : false,
}



func _ready():
	Global.player_start_position = Vector2(400, 750)
	Global.sense_mode_changed.connect(sense_change)
	Global.current_sense = Global.senses.SEE
	_on_see_button_pressed()
	
	
	
func _on_scent_0_pressed() -> void:
	if Global.current_sense == Global.senses.SMELL:
		if Global.player_POI_position != Global.POIs.SCENT_0:
			Global.visit_clue.emit(Vector2(%Scent0.position.x - 50, %Scent0.position.y + 0))
			await Global.arrived
			Global.player_POI_position = Global.POIs.SCENT_0
		else:
			dialogue = load("res://Dialogue/dialogue_missing.tres")
			DialogueManager.start_dialogue(dialogue)
			clues_interacted["Scent0"] = true
			clues_discovered["Scent1"] = true
			#%Scent1.add_to_group("smell")
			_on_smell_button_pressed()


func _on_scent_1_pressed() -> void:
	if Global.current_sense == Global.senses.SMELL:
		if Global.player_POI_position != Global.POIs.SCENT_1:
			Global.visit_clue.emit(Vector2(%Scent1.position.x - 50, %Scent1.position.y + 0))
			await Global.arrived
			Global.player_POI_position = Global.POIs.SCENT_1
		else:
			dialogue = load("res://Dialogue/dialogue_missing.tres")
			DialogueManager.start_dialogue(dialogue)
			clues_interacted["Scent1"] = true
			clues_discovered["Sound0"] = true
			#%Sound0.add_to_group("hear")


func _on_sound_0_pressed() -> void:
	if Global.current_sense == Global.senses.HEAR:
		if Global.player_POI_position != Global.POIs.SOUND_0:
			Global.visit_clue.emit(Vector2(%Sound0.position.x - 50, %Sound0.position.y + 0))
			await Global.arrived
			Global.player_POI_position = Global.POIs.SOUND_0
		else:
			dialogue = load("res://Dialogue/dialogue_missing.tres")
			DialogueManager.start_dialogue(dialogue)
			clues_interacted["Sound0"] = true
			await DialogueManager.dialogue_ended
			for n in 150:
				$Camera2D.position.x += 8
				await get_tree().create_timer(0.00000001).timeout
			Global.visit_clue.emit(Vector2(2120, 500))
			for n in 200:
				$Camera2D.position.x += 8
				await get_tree().create_timer(0.00000001).timeout
			await Global.arrived
			dialogue = load("res://Dialogue/dialogue_missing.tres")
			DialogueManager.start_dialogue(dialogue)
			clues_on_screen = get_tree().get_nodes_in_group("on_screen")
			for n in clues_on_screen:
				n.remove_from_group("on_screen")
			%SoftSpot.add_to_group("on_screen")
			%StallionHallucination1.add_to_group("on_screen")

func _on_soft_spot_pressed() -> void:
	if Global.player_POI_position != Global.POIs.SOFTSPOT:
		Global.visit_clue.emit(Vector2(%SoftSpot.position.x +400, %SoftSpot.position.y + 100))
		await Global.arrived
		Global.player_POI_position = Global.POIs.SOFTSPOT
	else:
		# lie down animation
		clues_interacted["Softspot"] = true
		cutscene_hallucination()


func cutscene_hallucination():
	await get_tree().create_timer(3).timeout
	%StallionHallucination1.show()
	#%HallucinationAnimationPlayer.play("hallucination")
	#await %HallucinationAnimationPlayer.animation_finished


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
	$BackgroundLayers/Parallax2D/Sky.self_modulate = Color(0.282, 0.282, 0.282)
	$BackgroundLayers/Parallax2D2/Middle.self_modulate = Color(0.282, 0.282, 0.282)
	$Parallax2D3/Foreground.self_modulate = Color(0.282, 0.282, 0.282)


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
	%Scent0.visible = true
	%Particles0.emitting = true
	if clues_discovered["Scent1"]:
		%Scent1.visible = true
		%Particles1.emitting = true


func hide_scents():
	%Scent0.visible = false
	%Particles0.emitting = false
	%Scent1.visible = false
	%Particles1.emitting = false


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
