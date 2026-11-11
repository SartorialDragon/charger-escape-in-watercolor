extends Control

var dialogue: DialogueData

var visible_clues: Array = []
var clues_on_screen: Array = []


# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
	"RockCluster" : false,
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
	Global.player_start_position = Vector2(400, 750)
	Global.sense_mode_changed.connect(sense_change)
	_on_see_button_pressed()


#func _on_rock_cluster_pressed() -> void:
	#Global.visit_clue.emit(Vector2(%RockCluster.position.x + 200, %RockCluster.position.y + 70))
	#await Global.arrived
	#Global.player_POI_position = Global.POIs.ROCKCLUSTER_0
	## play the respective clue stuff
	##dialogue = load("res://Dialogue/conversation0.tres")
	##DialogueManager.start_dialogue(dialogue)
	#clues_interacted["RockCluster"] = true
	
	
func _on_rock_cluster_0_pressed() -> void:
	if Global.player_POI_position == Global.POIs.ROCKCLUSTER_0:
		pass
	elif Global.player_POI_position == Global.POIs.ROCKCLUSTER_2:
		dialogue = load("res://Dialogue/E1_can't_reach.tres")
		DialogueManager.start_dialogue(dialogue)
	else:
		Global.visit_clue.emit(Vector2(%RockCluster0.position.x + 200, %RockCluster0.position.y + 70))
		await Global.arrived
		Global.player_POI_position = Global.POIs.ROCKCLUSTER_0
	

func _on_rock_cluster_1_pressed() -> void:
	if Global.player_POI_position == Global.POIs.ROCKCLUSTER_1:
		pass
	elif Global.player_POI_position != Global.POIs.ROCKCLUSTER_0 and Global.player_POI_position != Global.POIs.ROCKCLUSTER_2:
		dialogue = load("res://Dialogue/E1_can't_reach.tres")
		DialogueManager.start_dialogue(dialogue)
	else:
		Global.visit_clue.emit(Vector2(%RockCluster1.position.x + 200, %RockCluster1.position.y + 70))
		await Global.arrived
		Global.player_POI_position = Global.POIs.ROCKCLUSTER_1


func _on_rock_cluster_2_pressed() -> void:
	if Global.player_POI_position == Global.POIs.ROCKCLUSTER_2:
		pass
	elif Global.player_POI_position != Global.POIs.ROCKCLUSTER_1:
		dialogue = load("res://Dialogue/E1_can't_reach.tres")
		DialogueManager.start_dialogue(dialogue)
	else:
		Global.visit_clue.emit(Vector2(%RockCluster2.position.x + 200, %RockCluster2.position.y + 70))
		await Global.arrived
		Global.player_POI_position = Global.POIs.ROCKCLUSTER_2
		clues_interacted["RockCluster"] = true


	

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
		
		await DialogueManager.dialogue_ended
		if not clues_interacted["StallionScent"]:
			for n in 100:
				$Camera2D.position.x += 8
				await get_tree().create_timer(0.00000001).timeout
			clues_on_screen = get_tree().get_nodes_in_group("on_screen")
			%StallionScent.remove_from_group("on_screen")
			%RockSlide.add_to_group("on_screen")
			clues_interacted["StallionScent"] = true


func _on_rock_slide_pressed() -> void:
	if Global.player_POI_position == Global.POIs.ROCKCLUSTER_2 or Global.player_POI_position == Global.POIs.ROCKCLUSTER_1:
		dialogue = load("res://Dialogue/E1_can't_reach.tres")
		DialogueManager.start_dialogue(dialogue)
	else:
		Global.visit_clue.emit(Vector2(%RockSlide.position.x - 150, %RockSlide.position.y + 800))
		Global.player_POI_position = Global.POIs.ROCKSLIDE
		await Global.arrived
		# play the respective clue stuff
		await get_tree().create_timer(1).timeout # replace with interaction being an extra step
		%RockslideAnimationPlayer.play("kicked")
		clues_interacted["RockSlide"] = true
		play_cutscene_to_stallion()
		

func play_cutscene_to_stallion():
	for n in 150:
			$Camera2D.position.x += 8
			await get_tree().create_timer(0.00000001).timeout
	Global.visit_clue.emit(Vector2(%StallionHallucination0.position.x - 40, %StallionHallucination0.position.y + 100))
	for n in 350:
			$Camera2D.position.x += 8
			await get_tree().create_timer(0.00000001).timeout
	await Global.arrived
	%HallucinationAnimationPlayer.play("hallucination")
	
	#switch_scene()


func switch_scene():
	$SwitchScreen.show()
	var A = 0.0
	for n in 10:
		A += 0.1
		$SwitchScreen/Panel.self_modulate = Color(0.0, 0.0, 0.0, A)
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scene_1.tscn")


	
func play_scent():
	%ScentAnimationPlayer.play("scent_waft")
	await %ScentAnimationPlayer.animation_finished
	if not clues_interacted["StallionScent"]:
		play_scent()
	

func check_level_end():
	for n in clues_interacted:
		if clues_interacted[n] == false:
			return
	print("Level finished!")


func sense_change():
	if Global.current_sense == Global.senses.SEE:
		_on_see_button_pressed()
	if Global.current_sense == Global.senses.HEAR:
		_on_hear_button_pressed()
	if Global.current_sense == Global.senses.SMELL:
		_on_smell_button_pressed()


# ToDo: add hotkeys for the sense modes too!
func _on_see_button_pressed() -> void:
	visible_clues = get_tree().get_nodes_in_group("see")
	update_sense()


func _on_hear_button_pressed() -> void:
	visible_clues = get_tree().get_nodes_in_group("hear")
	update_sense()
	if clues_on_screen.has(%RockSlide) and not clues_discovered["StallionScent"]:
		%RockslideAnimationPlayer.play("rockslide")
		clues_discovered["StallionScent"] = true


func _on_smell_button_pressed() -> void:
	visible_clues = get_tree().get_nodes_in_group("smell")
	update_sense()
	if not clues_interacted["StallionScent"]:
		play_scent()
	

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
