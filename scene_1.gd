extends Control


var dialogue: DialogueData

var visible_clues: Array = []
var clues_on_screen: Array = []


func _ready():
	_on_see_button_pressed()
	

func _on_interactable_item_0_pressed() -> void:
	Global.visit_clue.emit(Vector2($"Interactable Item 0".position.x + 450, $"Interactable Item 0".position.y + 120)) 
	await Global.arrived
	# play the respective clue stuff
	dialogue = load("res://Dialogue/conversation0.tres")
	DialogueManager.start_dialogue(dialogue)
	Global.clues_interacted["Interactable 0"] = true
	if Global.clues_interacted["Interactable 1"] == true:
		Global.clues_discovered["Interactable Item 2"] = true
		update_sense()
		

func _on_interactable_item_1_pressed() -> void:
	Global.visit_clue.emit(Vector2($"Interactable Item 1".position.x - 100, $"Interactable Item 1".position.y + 120)) 
	await Global.arrived
	# play the respective clue stuff
	dialogue = load("res://Dialogue/conversation1.tres")
	DialogueManager.start_dialogue(dialogue)
	Global.clues_interacted["Interactable 1"] = true
	if Global.clues_interacted["Interactable 0"] == true:
		$"Interactable Item 2".add_to_group("on_screen")
		#Global.clues_discovered["Interactable Item 2"] = true
		update_sense()
		

func _on_interactable_item_2_pressed() -> void:
	Global.visit_clue.emit(Vector2($"Interactable Item 2".position.x - 100, $"Interactable Item 2".position.y + 120)) 
	await Global.arrived
	# play clue stuff
	dialogue = load("res://Dialogue/conversation2.tres")
	DialogueManager.start_dialogue(dialogue)
	var R = 1.0
	var G = 1.0
	var B = 1.0
	var A = 1.0
	if Global.clues_interacted["Interactable 2"] == false:
		for n in 250:
			R -= 0.005
			G -= 0.005
			B -= 0.005
			A -= 0.005
			$Camera2D.position.x += 8
			$TextureRect.modulate = Color(R, G, B, A)
			await get_tree().create_timer(0.00000001).timeout
	Global.clues_interacted["Interactable 2"] = true
	clues_on_screen = get_tree().get_nodes_in_group("on_screen")
	for n in clues_on_screen:
		n.remove_from_group("on_screen")
	$"Interactable Item 3".add_to_group("on_screen")
	$"Interactable Item 5".add_to_group("on_screen")


func _on_interactable_item_3_pressed() -> void:
	Global.visit_clue.emit(Vector2($"Interactable Item 3".position.x - 100, $"Interactable Item 3".position.y + 180)) 
	await Global.arrived # BUG i should make an "is already here?“ check.
	Global.clues_interacted["Interactable 3"] = true
	#Global.clues_discovered["Interactable Item 4"] = true
	$"Interactable Item 4".add_to_group("on_screen")
	update_sense()
	$"Interactable Item 4/AnimationPlayer4".play("fall")
	
	
func _on_interactable_item_4_pressed() -> void:
	dialogue = load("res://Dialogue/conversation4.tres")
	DialogueManager.start_dialogue(dialogue)
	Global.clues_interacted["Interactable 4"] = true
	$"Interactable Item 4".remove_from_group("on_screen")
	$"Interactable Item 4".hide()
	update_sense()
	await DialogueManager.dialogue_ended
	check_level_end()
	

func _on_interactable_item_5_pressed() -> void:
	Global.visit_clue.emit(Vector2($"Interactable Item 5".position.x - 0, $"Interactable Item 5".position.y + 120)) 
	await Global.arrived
	Global.visit_clue.emit(Vector2($"Interactable Item 5".position.x +20, $"Interactable Item 5".position.y + 120)) 
	await Global.arrived
	# play the respective clue stuff
	dialogue = load("res://Dialogue/conversation5.tres")
	DialogueManager.start_dialogue(dialogue)
	Global.clues_interacted["Interactable 5"] = true
	

func check_level_end():
	for n in Global.clues_interacted:
		if Global.clues_interacted[n] == false:
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
	

# updates showing all currently discovered clues
func update_sense():
	clues_on_screen = get_tree().get_nodes_in_group("on_screen")
	# sets all clues (currently on screen) of the current sense to discovered
	for n in clues_on_screen:
		if visible_clues.has(n):
				Global.clues_discovered[n.name] = true
	# shows all discovered clues currently on screen
	for n in clues_on_screen:
		if Global.clues_discovered[n.name]:
			n.show()
		
	
