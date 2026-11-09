extends Control

var dialogue: DialogueData

var visible_clues: Array = []
var clues_on_screen: Array = []

var rock_position

# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
	"RockCluster" : false,
	"StallionScent" : false,
}

# this means it has been clicked
var clues_interacted = {
	"RockCluster" : false,
	"StallionScent" : false,
}



func _ready():
	Global.player_start_position = Vector2(400, 750)
	rock_position = Vector2($RockCluster.position.x + 200, $RockCluster.position.y + 70)
	_on_see_button_pressed()
	
	

	
	

func _on_rock_cluster_pressed() -> void:
	Global.visit_clue.emit(Vector2(rock_position))
	Global.player_POI_position = Global.POIs.ROCKCLUSTER
	print($PlayerHorse.position)
	print(rock_position)
	await Global.arrived
	# play the respective clue stuff
	#dialogue = load("res://Dialogue/conversation0.tres")
	#DialogueManager.start_dialogue(dialogue)
	clues_interacted["RockCluster"] = true
	

func _on_scent_pressed() -> void:
	# play the respective clue stuff

# If click scent while on the ground: too high to reach
	if Global.player_POI_position != Global.POIs.ROCKCLUSTER or $StallionScent.position.x > $RockCluster.position.x + 200 :
		dialogue = load("res://Dialogue/E1_can't_reach.tres")
		DialogueManager.start_dialogue(dialogue)
	else:
		# change state to sniff: play a sniff animation once, then idle
		dialogue = load("res://Dialogue/E1_scent_remember.tres")
		DialogueManager.start_dialogue(dialogue)
		Global.clues_interacted["StallionScent"] = true
	
	
func play_scent():
	%ScentAnimationPlayer.play("scent_waft")
	await %ScentAnimationPlayer.animation_finished
	if not clues_interacted["StallionScent"]:
		print("no more")
		play_scent()
	

func check_level_end():
	for n in clues_interacted:
		if clues_interacted[n] == false:
			return
	print("Level finished!")


# ToDo: add hotkeys for the sense modes too!
func _on_see_button_pressed() -> void:
	visible_clues = get_tree().get_nodes_in_group("see")
	update_sense()


func _on_hear_button_pressed() -> void:
	visible_clues = get_tree().get_nodes_in_group("hear")
	update_sense()


func _on_smell_button_pressed() -> void:
	visible_clues = get_tree().get_nodes_in_group("smell")
	update_sense()
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
