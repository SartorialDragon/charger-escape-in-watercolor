extends Control


func _ready() -> void:
	Global.close_menu.connect(close_menu)
	if OS.has_feature("web"):
		$Panel/VBoxContainer/QuitButton.hide()
	if Global.clues_interacted["GetUp"]:
		$Panel/VBoxContainer/StartButton.hide()
		$Panel/VBoxContainer/ContinueButton.show()
	for n in 75:
		position.x += 9
		await get_tree().create_timer(0.00000001).timeout


func close_menu():
	for n in 75:
		position.x -= 9
		await get_tree().create_timer(0.00000001).timeout
	queue_free()


func _on_start_button_pressed() -> void:
	Global.game_started.emit()
	close_menu()


func _on_continue_button_pressed() -> void:
	close_menu()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
