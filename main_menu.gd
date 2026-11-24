extends Control


func _ready() -> void:
	Global.close_menu.connect(close_menu)
	if OS.has_feature("web"):
		$MainPanel/Panel/VBoxContainer/QuitButton.hide()
	if Global.clues_interacted["GetUp"]:
		$MainPanel/Panel/VBoxContainer/StartButton.hide()
		$MainPanel/Panel/VBoxContainer/ContinueButton.show()
	if Global.clues_interacted["Credits"]:
		$MainPanel/Panel/VBoxContainer/StartButton.hide()
		$MainPanel/Panel/VBoxContainer/ContinueButton.hide()
	$SettingsPanel/SettingsPanel/MusicSlider.value = Global.music_volume
	$SettingsPanel/SettingsPanel/VoiceSlider.value = Global.voice_volume
	$SettingsPanel/SettingsPanel/SfxSlider.value = Global.sfx_volume
	open_menu()


func _on_menu_button_pressed() -> void:
	open_menu()


func open_menu():
	$SFX.play()
	for n in 75:
		$MainPanel.position.x += 9
		await get_tree().create_timer(0.00000001).timeout


func open_settings_panel():
	if $SettingsPanel.position.x > 1414:
		$SFX.play()
	for n in 75:
		if $SettingsPanel.position.x > 1414:
			$SettingsPanel.position.x -= 16
			await get_tree().create_timer(0.00000001).timeout


func close_menu():
	$SFX.play()
	for n in 75:
		$MainPanel.position.x -= 9
		$SettingsPanel.position.x += 16
		await get_tree().create_timer(0.00000001).timeout
	queue_free()
	
	
func close_settings_panel():
	if $SettingsPanel.position.x < 2614.0:
		$SFX.play()
	for n in 75:
		if $SettingsPanel.position.x < 2614.0:
			$SettingsPanel.position.x += 16
			await get_tree().create_timer(0.00000001).timeout
	$SettingsPanel/SettingsPanel.hide()
	$SettingsPanel/QuitPanel.hide()
	

func _on_start_button_pressed() -> void:
	Global.game_started.emit()
	close_menu()


func _on_continue_button_pressed() -> void:
	Global.close_menu.emit()


func _on_settings_button_pressed() -> void:
	if not $SettingsPanel/SettingsPanel.visible:
		$SettingsPanel/SettingsPanel.show()
		$SettingsPanel/QuitPanel.hide()
		open_settings_panel()
	else:
		close_settings_panel()

func _on_music_volume_set(value: float):
	Global.music_volume = value
	Global.music_volume_changed.emit()
	
func _on_voice_volume_set(value: float):
	Global.voice_volume = value
	Global.voice_volume_changed.emit()

func _on_sfx_volume_set(value: float):
	Global.sfx_volume = value

func _on_quit_button_pressed() -> void:
	$SettingsPanel/QuitPanel.show()
	$SettingsPanel/SettingsPanel.hide()
	open_settings_panel()


func _on_yes_button_pressed() -> void:
	get_tree().quit()


func _on_no_button_pressed() -> void:
	close_settings_panel()
