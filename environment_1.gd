extends Control

var dialogue: NodePath

var cursor_default = load("res://ArtAssets/Cursor_Sepia.png")
var cursor_POI = load("res://ArtAssets/Cursor_Brown.png")

var visible_clues: Array = []
var clues_on_screen: Array = []


# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
	"RockCluster" : false,
	"RockCluster0" : false,
	"RockCluster1" : false,
	"RockCluster2" : false,
	"RockCluster3" : false,
	"StallionScent" : false,
	"RockSlide" : false,
}

# this means it has been clicked
var clues_interacted = {
	"RockCluster" : false,
	"StallionScent" : false,
	"RockSlide" : false,
}



func _ready():
	Input.set_custom_mouse_cursor(cursor_default)
	Input.set_custom_mouse_cursor(cursor_POI, Input.CURSOR_POINTING_HAND)
	Global.player_start_position = Vector2(700, 750)
	Global.sense_mode_changed.connect(sense_change)
	Global.game_started.connect(start_game)
	Global.got_up.connect(	_on_get_up)
	_on_hear_button_pressed()
	
	
func start_game():
	$SwitchScreen.show()
	# screen darkens
	var A = 0.0
	for n in 10:
		A += 0.1
		$SwitchScreen/Panel.self_modulate = Color(0.0, 0.0, 0.0, A)
		await get_tree().create_timer(0.1).timeout
	dialogue = "res://Dialogue/20_intro.tres"
	DialogueManager.start_dialogue(dialogue, 0)
	await DialogueManager.dialogue_ended
	# screen brightens
	A = 1.0
	for n in 10:
		A -= 0.1
		$SwitchScreen/Panel.self_modulate = Color(0.0, 0.0, 0.0, A)
		await get_tree().create_timer(0.1).timeout
	# camera scrolls
	for n in 110:
		$Camera2D.position.x += 8
		await get_tree().create_timer(0.00000001).timeout
	#await get_tree().create_timer(5).timeout
	#if not Global.clues_interacted["Echo"]:
		#Global.hint_needed.emit("Echo")
	$SwitchScreen.hide()
	
	
func _on_get_up():
	%RockCluster.add_to_group("see")
	Global.clues_interacted["GetUp"] = true
	dialogue = "res://Dialogue/19_tutorial.tres"
	DialogueManager.start_dialogue(dialogue, 0)
	await DialogueManager.dialogue_ended
	
	
func _on_rock_cluster_0_pressed() -> void:
	if Global.player_POI_position == Global.POIs.ROCKCLUSTER_0:
		pass
	elif Global.player_POI_position == Global.POIs.ROCKCLUSTER_2 or Global.player_POI_position == Global.POIs.ROCKCLUSTER_3:
		dialogue = "res://Dialogue/06_can't_reach.tres"
		DialogueManager.start_dialogue(dialogue, 1)
	else:
		if Global.current_sense != Global.senses.SEE:
			dialogue = "res://Dialogue/05_need_to_see.tres"
			DialogueManager.start_dialogue(dialogue, 1)
		else:
			Global.visit_clue.emit(Vector2(%RockCluster.position.x +380, %RockCluster.position.y + 320))
			await Global.arrived
			Global.player_POI_position = Global.POIs.ROCKCLUSTER_0
	

func _on_rock_cluster_1_pressed() -> void:
	if Global.player_POI_position == Global.POIs.ROCKCLUSTER_1:
		pass
	elif Global.player_POI_position != Global.POIs.ROCKCLUSTER_0 and Global.player_POI_position != Global.POIs.ROCKCLUSTER_2:
		dialogue = "res://Dialogue/06_can't_reach.tres"
		DialogueManager.start_dialogue(dialogue, 1)
	else:
		if Global.current_sense != Global.senses.SEE:
			dialogue = "res://Dialogue/05_need_to_see.tres"
			DialogueManager.start_dialogue(dialogue, 1)
		else:
			Global.visit_clue.emit(Vector2(%RockCluster.position.x + 620, %RockCluster.position.y + 200))
			await Global.arrived
			Global.player_POI_position = Global.POIs.ROCKCLUSTER_1


func _on_rock_cluster_2_pressed() -> void:
	if Global.player_POI_position == Global.POIs.ROCKCLUSTER_2:
		pass
	elif Global.player_POI_position != Global.POIs.ROCKCLUSTER_1 and Global.player_POI_position != Global.POIs.ROCKCLUSTER_3:
		dialogue = "res://Dialogue/06_can't_reach.tres"
		DialogueManager.start_dialogue(dialogue, 1)
	else:
		if Global.current_sense != Global.senses.SEE:
			dialogue = "res://Dialogue/05_need_to_see.tres"
			DialogueManager.start_dialogue(dialogue, 1)
		else:
			Global.visit_clue.emit(Vector2(%RockCluster.position.x + 440, %RockCluster.position.y + 120))
			await Global.arrived
			Global.player_POI_position = Global.POIs.ROCKCLUSTER_2


func _on_rock_cluster_3_pressed() -> void:
	if Global.player_POI_position == Global.POIs.ROCKCLUSTER_3:
		pass
	elif Global.player_POI_position != Global.POIs.ROCKCLUSTER_2:
		dialogue = "res://Dialogue/06_can't_reach.tres"
		DialogueManager.start_dialogue(dialogue, 1)
	else:
		if Global.current_sense != Global.senses.SEE:
			dialogue = "res://Dialogue/05_need_to_see.tres"
			DialogueManager.start_dialogue(dialogue, 1)
		else:
			Global.visit_clue.emit(Vector2(%RockCluster.position.x + 610, %RockCluster.position.y + 10))
			await Global.arrived
			Global.player_POI_position = Global.POIs.ROCKCLUSTER_3
			clues_interacted["RockCluster"] = true


func _on_scent_pressed() -> void:
	# play the respective clue stuff

# If click scent while on the ground: too high to reach
	if Global.player_POI_position != Global.POIs.ROCKCLUSTER_3 or %StallionScent.position.x > %RockCluster.position.x + 600 :
		dialogue = "res://Dialogue/06_can't_reach.tres"
		DialogueManager.start_dialogue(dialogue, 1)
	else:
		# change state to sniff: play a sniff animation once, then idle
		dialogue = "res://Dialogue/07_scent_remember.tres"
		DialogueManager.start_dialogue(dialogue, 0)
		%StallionScent.visible = false
		await DialogueManager.dialogue_ended
		if not clues_interacted["StallionScent"]:
			for n in 100:
				$Camera2D.position.x += 8
				await get_tree().create_timer(0.00000001).timeout
			clues_on_screen = get_tree().get_nodes_in_group("on_screen")
			%StallionScent.remove_from_group("on_screen")
			clues_interacted["StallionScent"] = true
			
			sense_change() # to trigger the rockslide if already in hearing mode


func _on_rock_slide_pressed() -> void:
	if Global.player_POI_position == Global.POIs.ROCKCLUSTER_3 or Global.player_POI_position == Global.POIs.ROCKCLUSTER_2 or Global.player_POI_position == Global.POIs.ROCKCLUSTER_1:
		dialogue = "res://Dialogue/06_can't_reach.tres"
		DialogueManager.start_dialogue(dialogue, 1)
	else:
		if Global.player_POI_position != Global.POIs.ROCKSLIDE:
			#if Global.current_sense == Global.senses.HEAR:
				#dialogue = load("res://Dialogue/13_can't_hear.tres")
				#DialogueManager.start_dialogue(dialogue)
			#elif Global.current_sense == Global.senses.SMELL:
				#dialogue = load("res://Dialogue/14_can't_smell.tres")
				#DialogueManager.start_dialogue(dialogue)
			#elif Global.current_sense == Global.senses.SEE:
			Global.visit_clue.emit(Vector2(%RockSlide.position.x - 100, %RockSlide.position.y + 600))
			await Global.arrived
			Global.player_POI_position = Global.POIs.ROCKSLIDE
		else:
			# play the respective clue stuff
			%RockslideAnimationPlayer.play("kicked")
			clues_interacted["RockSlide"] = true
			%RockSlide.disabled = true
			dialogue = "res://Dialogue/21_rockslide.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			await DialogueManager.dialogue_ended
			play_cutscene_to_stallion()
		

func play_cutscene_to_stallion():
	for n in 150:
			$Camera2D.position.x += 8
			await get_tree().create_timer(0.00000001).timeout
	Global.visit_clue.emit(Vector2(%StallionHallucination0.position.x - 40, %StallionHallucination0.position.y + 100))
	for n in 400:
			$Camera2D.position.x += 8
			await get_tree().create_timer(0.00000001).timeout
	if Global.current_state.name == "Trot":
		await Global.arrived
	await get_tree().create_timer(1).timeout
	%HallucinationAnimationPlayer.play("hallucination")
	await %HallucinationAnimationPlayer.animation_finished
	await get_tree().create_timer(1).timeout
	Global.visit_clue.emit(Vector2(5500, 700))
	await get_tree().create_timer(1).timeout
	switch_scene()


func switch_scene():
	$SwitchScreen.show()
	var A = 0.0
	for n in 10:
		A += 0.1
		$SwitchScreen/Panel.self_modulate = Color(0.0, 0.0, 0.0, A)
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://environment_2.tscn")


	
func play_scent():
	%ScentAnimationPlayer.play("scent_waft")
	await %ScentAnimationPlayer.animation_finished
	if not clues_interacted["StallionScent"]:
		play_scent()


func sense_change():
	if Global.current_sense == Global.senses.SEE:
		_on_see_button_pressed()
	if Global.current_sense == Global.senses.HEAR:
		_on_hear_button_pressed()
	if Global.current_sense == Global.senses.SMELL:
		_on_smell_button_pressed()


# ToDo: add hotkeys for the sense modes too!
func _on_see_button_pressed() -> void:
	var from_position = $MusicAudio.get_playback_position()
	$MusicAudio.stream = load("res://Music/E1 Seeing.mp3")
	$MusicAudio.play(from_position)
	hide_sounds()
	hide_scents()
	lighten_surroundings()
	normalize_music()
	visible_clues = get_tree().get_nodes_in_group("see")
	update_sense()


func _on_hear_button_pressed() -> void:
	var from_position = $MusicAudio.get_playback_position()
	$MusicAudio.stream = load("res://Music/E1 Hearing.mp3")
	$MusicAudio.play(from_position)
	hide_scents()
	darken_surroundings()
	muffle_music()
	show_sounds()
	visible_clues = get_tree().get_nodes_in_group("hear")
	
	# this should go somewhere different
	if clues_interacted["StallionScent"] and not clues_discovered["RockSlide"]:
		%RockslideAnimationPlayer.play("rockslide")
		#$SFXAudio.stream = load("res://Assets/freesound_community-stones-falling-6375.mp3")
		#$SFXAudio.play()
		%RockSlide.add_to_group("on_screen")
	update_sense()


func _on_smell_button_pressed() -> void:
	var from_position = $MusicAudio.get_playback_position()
	$MusicAudio.stream = load("res://Music/E1 Sniffing.mp3")
	$MusicAudio.play(from_position)
	hide_sounds()
	normalize_music()
	darken_surroundings()
	show_scents()
	visible_clues = get_tree().get_nodes_in_group("smell")
	update_sense()
	if not clues_interacted["StallionScent"]:
		play_scent()
	
	
func darken_surroundings():
	$BackgroundLayers/Parallax2D/Sky.self_modulate = Color(0.5, 0.5, 0.5)
	$BackgroundLayers/Parallax2D2/Middle.modulate = Color(0.5, 0.5, 0.5)
	$Parallax2D3/Foreground.self_modulate = Color(0.5, 0.5, 0.5)
	%RockCluster.self_modulate = Color(0.5, 0.5, 0.5)
	%RockSlide.self_modulate = Color(0.5, 0.5, 0.5)


func lighten_surroundings():
	$BackgroundLayers/Parallax2D/Sky.self_modulate = Color(1.0, 1.0, 1.0)
	$BackgroundLayers/Parallax2D2/Middle.modulate = Color(1.0, 1.0, 1.0)
	$Parallax2D3/Foreground.self_modulate = Color(1.0, 1.0, 1.0)
	%RockCluster.self_modulate = Color(1.0, 1.0, 1.0)
	%RockSlide.self_modulate = Color(1.0, 1.0, 1.0)
	

func muffle_music():
	$MusicAudio.volume_db = -7.153
	#$MusicAudio.pitch_scale = 0.81
	
	
func normalize_music():
	$MusicAudio.volume_db = 0.0
	$MusicAudio.pitch_scale = 1.0


func show_scents():
	if not clues_interacted["StallionScent"]:
		$StallionScent/CPUParticles2D.visible = true
		$StallionScent/CPUParticles2D.emitting = true
	

func hide_scents():
	$StallionScent/CPUParticles2D.visible = false
	$StallionScent/CPUParticles2D.emitting = false


func show_sounds():
	if not clues_interacted["RockSlide"]:
		if not clues_discovered["RockSlide"]:
			%RockSlide.texture_normal = load("res://ArtAssets/rock.png")
		else:
			%RockSlide.texture_normal = load("res://ArtAssets/rock.png")


func hide_sounds():
	pass
		


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
