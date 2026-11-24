extends Control




func _ready() -> void:
	Global.close_menu.connect(close_menu)
	if OS.has_feature("web"):
		%QuitButton.hide()
		$RightPanel/SettingsPanel/TextureRect4.hide()
	if Global.clues_interacted["GetUp"]:
		%StartButton.hide()
		%ContinueButton.show()
	if Global.clues_interacted["Credits"]:
		%StartButton.hide()
		%ontinueButton.hide()
	%MasterSlider.value = Global.master_volume
	%MusicSlider.value = Global.music_volume
	%VoiceSlider.value = Global.voice_volume
	%SfxSlider.value = Global.sfx_volume
	open_menu()


func _on_menu_button_pressed() -> void:
	open_menu()


func open_menu():
	$SFX.play()
	for n in 75:
		$MainPanel.position.x += 9
		await get_tree().create_timer(0.00000001).timeout


func open_settings_panel():
	if $RightPanel.position.x > 1414:
		$SFX.play()
	for n in 75:
		if $RightPanel.position.x > 1414:
			$RightPanel.position.x -= 16
			await get_tree().create_timer(0.00000001).timeout


func close_menu():
	$SFX.play()
	for n in 75:
		$MainPanel.position.x -= 9
		$RightPanel.position.x += 16
		await get_tree().create_timer(0.00000001).timeout
	queue_free()
	
	
func close_settings_panel():
	if $RightPanel.position.x < 2614.0:
		$SFX.play()
	for n in 75:
		if $RightPanel.position.x < 2614.0:
			$RightPanel.position.x += 16
			await get_tree().create_timer(0.00000001).timeout
	%SettingsPanel.hide()
	%QuitPanel.hide()
	

func _on_start_button_pressed() -> void:
	Global.game_started.emit()
	close_menu()


func _on_continue_button_pressed() -> void:
	Global.close_menu.emit()


func _on_settings_button_pressed() -> void:
	if not %SettingsPanel.visible:
		%SettingsPanel.show()
		%QuitPanel.hide()
		open_settings_panel()
	else:
		close_settings_panel()


func _on_master_volume_set(value: float):
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	Global.master_volume = value


func _on_music_volume_set(value: float):
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	Global.music_volume = value
	Global.music_volume_changed.emit()
	
	
func _on_voice_volume_set(value: float):
	if not $Voice.playing:
		$Voice.play()
	var bus_index = AudioServer.get_bus_index("VA")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	Global.voice_volume = value
	#Global.voice_volume_changed.emit()


func _on_sfx_volume_set(value: float):
	if not $SFX.playing:
		$SFX.play()
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	Global.sfx_volume = value
	#Global.sfx_volume_changed.emit()


func _on_quit_button_pressed() -> void:
	%QuitPanel.show()
	%SettingsPanel.hide()
	open_settings_panel()


func _on_yes_button_pressed() -> void:
	get_tree().quit()


func _on_no_button_pressed() -> void:
	close_settings_panel()


func _on_fullscreen_button_pressed() -> void:
	var mode := DisplayServer.window_get_mode()
	var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
	if is_window:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
		%FullscreenButton.text = "ON"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		%FullscreenButton.text = "OFF"
