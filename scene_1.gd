extends Control





func _ready():
	#$PlayerHorse/AnimationPlayer.play("start position")
	pass
	

func _on_interactable_item_0_pressed() -> void:
	Global.visit_clue.emit(Vector2($"Interactable Item 0".position.x + 450, $"Interactable Item 0".position.y + 120)) 
	Global.clues_found["Interactable 0"] = true
	await Global.arrived
	# play the respective clue stuff
	$ClueDialogue.show()
	await $ClueDialogue/Button.pressed
	$ClueDialogue.hide()
	if Global.clues_found["Interactable 1"] == true:
		$"Interactable Item 2".show()
		

func _on_interactable_item_1_pressed() -> void:
	Global.visit_clue.emit(Vector2($"Interactable Item 1".position.x - 100, $"Interactable Item 1".position.y + 120)) 
	Global.clues_found["Interactable 1"] = true
	await Global.arrived
	# play the respective clue stuff
	$ClueDialogue.show()
	await $ClueDialogue/Button.pressed
	$ClueDialogue.hide()
	if Global.clues_found["Interactable 0"] == true:
		$"Interactable Item 2".show()
		

func _on_interactable_item_2_pressed() -> void:
	Global.visit_clue.emit(Vector2($"Interactable Item 2".position.x - 100, $"Interactable Item 2".position.y + 120)) 
	await Global.arrived
	# play clue stuff
	$ClueDialogue.show()
	await $ClueDialogue/Button.pressed
	$ClueDialogue.hide()
	var R = 1.0
	var G = 1.0
	var B = 1.0
	var A = 1.0
	if Global.clues_found["Interactable 2"] == false:
		for n in 200:
			R -= 0.005
			G -= 0.005
			B -= 0.005
			A -= 0.005
			$Camera2D.position.x += 8
			$TextureRect.modulate = Color(R, G, B, A)
			await get_tree().create_timer(0.00000001).timeout
	Global.clues_found["Interactable 2"] = true


func _on_interactable_item_3_pressed() -> void:
	Global.visit_clue.emit(Vector2($"Interactable Item 3".position.x - 100, $"Interactable Item 3".position.y + 180)) 
	Global.clues_found["Interactable 3"] = true
	await Global.arrived
	if not Global.clues_found["Interactable 4"] == true:
		$"Interactable Item 4".show()
		$"Interactable Item 4/AnimationPlayer4".play("fall")
	
	
func _on_interactable_item_4_pressed() -> void:
	$ClueDialogue.show()
	await $ClueDialogue/Button.pressed
	$ClueDialogue.hide()
	Global.clues_found["Interactable 4"] = true
	$"Interactable Item 4".hide()
	check_level_end()


func check_level_end():
	for n in Global.clues_found:
		if Global.clues_found[n] == false:
			return
	print("Level finished!")
