extends Control

var dialogue: DialogueData

var cursor_default = load("res://Assets/Cursor_Sepia.png")
var cursor_POI = load("res://Assets/Cursor_Brown.png")

var visible_clues: Array = []
var clues_on_screen: Array = []




# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
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
	Input.set_custom_mouse_cursor(cursor_default)
	Input.set_custom_mouse_cursor(cursor_POI, Input.CURSOR_POINTING_HAND)
	Global.player_start_position = Vector2(400, 750)
	Global.sense_mode_changed.connect(sense_change)
	Global.current_sense = Global.senses.SEE
	_on_see_button_pressed()
	

func _physics_process(_delta: float) -> void:
	if clues_interacted["Bucket"] == true and clues_interacted["Smoldering"] == false:
		%Bucket.position = Vector2($BackgroundLayers/Parallax2D2/PlayerHorse.position.x -170, $BackgroundLayers/Parallax2D2/PlayerHorse.position.y - 170)
	
	
	
func _on_tree_0_pressed() -> void:
	if Global.player_POI_position != Global.POIs.TREE_0:
		Global.visit_clue.emit(Vector2(%Tree0.position.x + 80, %Tree0.position.y + 260))
		await Global.arrived
		Global.player_POI_position = Global.POIs.TREE_0
	else:
		if Global.current_sense == Global.senses.SEE:
			dialogue = load("res://Dialogue/E2_can't_see.tres")
			DialogueManager.start_dialogue(dialogue)
		elif Global.current_sense == Global.senses.HEAR:
			dialogue = load("res://Dialogue/E2_can't_hear.tres")
			DialogueManager.start_dialogue(dialogue)
		elif Global.current_sense == Global.senses.SMELL:
			%ManeHair.visible = true
			clues_interacted["Tree0"] = true


func _on_mane_hair_pressed() -> void:
	if Global.player_POI_position != Global.POIs.TREE_0:
		Global.visit_clue.emit(Vector2(%Tree0.position.x + 80, %Tree0.position.y + 260))
		await Global.arrived
		Global.player_POI_position = Global.POIs.TREE_0
	else:
		if Global.current_sense == Global.senses.SEE:
			pass
		elif Global.current_sense == Global.senses.HEAR:
			pass
		elif Global.current_sense == Global.senses.SMELL:
			dialogue = load("res://Dialogue/E2_his_mane.tres")
			DialogueManager.start_dialogue(dialogue)
			await DialogueManager.dialogue_ended
			if not clues_interacted["ManeHair"]:
				for n in 50:
					$Camera2D.position.x += 8
					await get_tree().create_timer(0.00000001).timeout
				Global.visit_clue.emit(Vector2(2600, 550))
				for n in 350:
					$Camera2D.position.x += 8
					await get_tree().create_timer(0.00000001).timeout
				await Global.arrived
				clues_on_screen = get_tree().get_nodes_in_group("on_screen")
				%Tree0.remove_from_group("on_screen")
				%ManeHair.remove_from_group("on_screen")
				%Bucket.add_to_group("on_screen")
				%Stream.add_to_group("on_screen")
				%Tree1.add_to_group("on_screen")
				%Tree2.add_to_group("on_screen")
				%Tree3.add_to_group("on_screen")
				%Tree4.add_to_group("on_screen")
				clues_interacted["ManeHair"] = true


func _on_bucket_pressed() -> void:
	if Global.player_POI_position != Global.POIs.BUCKET:
		Global.visit_clue.emit(Vector2(%Bucket.position.x + 120, %Bucket.position.y + 60))
		await Global.arrived
		Global.player_POI_position = Global.POIs.BUCKET
	else:
		# pick up bucket
		dialogue = load("res://Dialogue/E2_human_waste.tres")
		DialogueManager.start_dialogue(dialogue)
		clues_interacted["Bucket"] = true
		%Bucket.rotation = 0.0


func _on_stream_pressed() -> void:
	if Global.player_POI_position != Global.POIs.STREAM:
		Global.visit_clue.emit(Vector2(%Stream.position.x + 400, %Stream.position.y + 100))
		await Global.arrived
		Global.player_POI_position = Global.POIs.STREAM
	else:
		if clues_interacted["Bucket"]:
			%Bucket.texture_normal = load("res://ArtAssets/bucket_full.png")


func _on_tree_1_pressed() -> void:
	_on_tree_pressed(%Tree1, %TreeParticles1)
	
func _on_tree_2_pressed() -> void:
	_on_tree_pressed(%Tree2, %TreeParticles2)

func _on_tree_3_pressed() -> void:
	_on_tree_pressed(%Tree3, %TreeParticles3)

func _on_tree_4_pressed() -> void:
	_on_tree_pressed(%Tree4, %TreeParticles4)
	

func _on_tree_pressed(tree, particle):
	if Global.player_POI_position != Global.POIs.TREES:
		Global.visit_clue.emit(Vector2(tree.position.x - 120, tree.position.y + 260))
		await Global.arrived
		Global.player_POI_position = Global.POIs.TREES
	elif clues_interacted["Smoldering"]:
		if tree.is_in_group("on_screen"):
			move_through_trees()
	else:
		if not clues_interacted["Bucket"]:
			dialogue = load("res://Dialogue/E2_can't_pass.tres")
			DialogueManager.start_dialogue(dialogue)
		else:
			if not %Bucket.texture_normal == load("res://ArtAssets/bucket_full.png"):
				pass
			else:
				if not clues_interacted[tree.name]:
					%Bucket.texture_normal = load("res://ArtAssets/bucket_empty.png")
					particle.emitting = false
					clues_interacted[tree.name] = true
					clues_interacted["Smoldering"] = true
					for n in 4:
						if clues_interacted["Tree"+str(n+1)] == false:
							clues_interacted["Smoldering"] = false
		

func move_through_trees():
	for n in 50:
		$Camera2D.position.x += 8
		await get_tree().create_timer(0.00000001).timeout
	Global.visit_clue.emit(Vector2(4500, 650))
	for n in 260:
		$Camera2D.position.x += 8
		await get_tree().create_timer(0.00000001).timeout
	await Global.arrived
	clues_on_screen = get_tree().get_nodes_in_group("on_screen")
	for n in clues_on_screen:
		n.remove_from_group("on_screen")
	%StallionScent.add_to_group("on_screen")
	

func _on_stallion_scent_pressed() -> void:
	pass # Replace with function body.


func _on_scent_pressed() -> void:
	# play the respective clue stuff

# If click scent while on the ground: too high to reach
	if Global.player_POI_position != Global.POIs.ROCKCLUSTER_2 or %StallionScent.position.x > %RockCluster2.position.x + 200 :
		dialogue = load("res://Dialogue/E1_can't_reach.tres")
		DialogueManager.start_dialogue(dialogue)
	else:
		# change state to sniff: play a sniff animation once, then idle
		dialogue = load("res://Dialogue/E1_scent_remember.tres")
		DialogueManager.start_dialogue(dialogue)
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



func play_cutscene_to_stallion():
	for n in 150:
			$Camera2D.position.x += 8
			await get_tree().create_timer(0.00000001).timeout
	Global.visit_clue.emit(Vector2(%StallionHallucination0.position.x - 40, %StallionHallucination0.position.y + 100))
	for n in 400:
			$Camera2D.position.x += 8
			await get_tree().create_timer(0.00000001).timeout
	await Global.arrived
	%HallucinationAnimationPlayer.play("hallucination")
	await %HallucinationAnimationPlayer.animation_finished
	await get_tree().create_timer(1).timeout
	Global.visit_clue.emit(Vector2(5500, 525))
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
	get_tree().change_scene_to_file("res://environment_3.tscn")


	
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
	if not clues_interacted["StallionScent"]:
		play_scent()
	
	
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
	if not clues_interacted["StallionScent"]:
		$StallionScent/CPUParticles2D.visible = true
		$StallionScent/CPUParticles2D.emitting = true
	if %Tree0.is_in_group("on_screen"):
		%TreeParticles0.visible = true
		%TreeParticles0.emitting = true
		# actually this should only switch on/of scent marking particles, not the smoke itself
			
	

func hide_scents():
	$StallionScent/CPUParticles2D.visible = false
	$StallionScent/CPUParticles2D.emitting = false
	%TreeParticles0.visible = false
	%TreeParticles0.emitting = false

func show_sounds():
	#if not clues_interacted["RockSlide"]:
		#if not clues_discovered["RockSlide"]:
			#%RockSlide.texture_normal = load("res://Assets/rock2.png")
		#else:
			#%RockSlide.texture_normal = load("res://Assets/rock3.png")
	pass

func hide_sounds():
	#if not clues_interacted["RockSlide"]:
		#if not clues_discovered["RockSlide"]:
			#%RockSlide.texture_normal = load("res://Assets/rock0.png")
		#else:
			#%RockSlide.texture_normal = load("res://Assets/rock1.png")
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
