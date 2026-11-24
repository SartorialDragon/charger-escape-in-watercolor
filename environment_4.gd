extends Control

var dialogue: NodePath

var cursor_default = load("res://ArtAssets/Cursor_Sepia.png")
var cursor_POI = load("res://ArtAssets/Cursor_Brown.png")

var visible_clues: Array = []
var clues_on_screen: Array = []

@onready var player_horse: CharacterBody2D = $BackgroundLayers/Parallax2D2/PlayerHorse

var soundtrack: String

# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
	"Destroy0" : false,
	"Destroy1" : false,
	"Destroy2" : false,
	"Destroy3" : false,
	"Destroy4" : false,
	"Spring" : false,
	"Rage" : false,
	"Grief" : false,
	}

# this means it has been clicked
var clues_interacted = {
	"Destroy0" : false,
	"Destroy1" : false,
	"Destroy2" : false,
	"Destroy3" : false,
	"Destroy4" : false,
	"Spring" : false,
	"Rage" : false,
	"Grief" : false,
}


func _ready():
	Input.set_custom_mouse_cursor(cursor_default)
	Input.set_custom_mouse_cursor(cursor_POI, Input.CURSOR_POINTING_HAND)
	Global.player_start_position = Vector2(400, 750)
	Global.sense_mode_changed.connect(sense_change)
	Global.close_menu.connect(show_menu_button)
	Global.music_volume_changed.connect(on_music_volume_changed)
	Global.current_sense = Global.senses.SEE
	_on_see_button_pressed()
	Global.clues_interacted["GetUp"] = true
	await get_tree().create_timer(1).timeout
	dialogue = "res://Dialogue/32_E4_start.tres"
	DialogueManager.start_dialogue(dialogue, 0)
	await DialogueManager.dialogue_ended
	move_forward()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") and Global.clues_interacted["GetUp"]:
		_on_menu_button_pressed()


func _on_menu_button_pressed() -> void:
	if %UILayer.has_node("MainMenu"):
		Global.close_menu.emit()
		$UILayer/MenuButton.show()
	else:
		show_menu()
		$UILayer/MenuButton.hide()


func show_menu_button():
	$UILayer/MenuButton.show()


func show_menu():
	var scene = load("res://main_menu.tscn")
	var instance = scene.instantiate()
	$UILayer.add_child(instance)
	

func move_forward():
	Global.visit_clue.emit(Vector2(player_horse.position.x + 3550, player_horse.position.y + 0))
	for n in 520:
		$Camera2D.position.x += 8
		await get_tree().create_timer(0.00001).timeout
	if Global.current_state.name == "Trot":
		await Global.arrived
	dialogue = "res://Dialogue/33_finding_him.tres"
	DialogueManager.start_dialogue(dialogue, 0)
	await DialogueManager.dialogue_ended
	Global.visit_clue.emit(Vector2(player_horse.position.x + 150, player_horse.position.y + 0))
	for n in 320:
			$Camera2D.position.x += 2
			await get_tree().create_timer(0.00000001).timeout
	var A = 1.0
	for n in 10:
		A -= 0.1
		$Parallax2D4.modulate = Color(1.0, 1.0, 1.0, A)
		await get_tree().create_timer(0.1).timeout


func _on_spring_pressed() -> void:
	if Global.player_POI_position != Global.POIs.SPRING:
		%BentTree.z_index = 0
		if not clues_interacted["Spring"]:
			Global.visit_clue.emit(Vector2(%Spring.position.x +100, %Spring.position.y + 10))
		else:
			if clues_interacted["Rage"]:
				Global.visit_clue.emit(Vector2(%Spring.position.x +150, %Spring.position.y + 0))
		await Global.arrived
		Global.player_POI_position = Global.POIs.SPRING
	else:
		if not clues_interacted["Spring"]:
			clues_interacted["Spring"] = true
			dialogue = "res://Dialogue/46_finding_him_2.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			await DialogueManager.dialogue_ended
			cutscene_dead()
		else:
			if clues_interacted["Rage"] and not clues_interacted["Grief"]:
				clues_interacted["Grief"] = true
				Global.clues_interacted["GetUp"] = false
				await get_tree().create_timer(2).timeout
				dialogue = "res://Dialogue/39_i_love_him.tres"
				DialogueManager.start_dialogue(dialogue, 0)
				await DialogueManager.dialogue_ended
				cutscene_grief()


func cutscene_dead():
	$StillImageLayer.show()
	var A = 0.0
	for n in 10:
		A += 0.1
		$StillImageLayer/Panel.self_modulate = Color(0.0, 0.0, 0.0, A)
		$StillImageLayer/Panel/StillImage.self_modulate = Color(1.0, 1.0, 1.0, A)
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(4).timeout
	$StillImageLayer.hide()
	clues_discovered["Destroy0"] = true
	Global.speed = 400
	%RedParticles0.emitting = true
	$RageLayer.show()
	if OS.has_feature("web"):
		$RageLayer/Workaround.show()
		$RageLayer/Workaround/AnimationPlayer.play("rage")
	else:
		$RageLayer/SmokeParticles.show()
		$RageLayer/SmokeParticles.emitting = true
	#$RageLayer/AnimationPlayer.play("rage")


func _on_destroy_0_pressed() -> void:
	_on_destroy(Global.POIs.DESTROY0, %Destroy0, %RedParticles0, "res://Dialogue/34_rage0.tres", %Destroy1)
	
func _on_destroy_1_pressed() -> void:
	_on_destroy(Global.POIs.DESTROY1, %Destroy1, %RedParticles1, "res://Dialogue/35_rage1.tres", %Destroy3)

func _on_destroy_2_pressed() -> void:
	_on_destroy(Global.POIs.DESTROY2, %Destroy2, %RedParticles2, "res://Dialogue/38_rage4.tres", null)

func _on_destroy_3_pressed() -> void:
	_on_destroy(Global.POIs.DESTROY3, %Destroy3, %RedParticles3, "res://Dialogue/36_rage2.tres", %Destroy4)

func _on_destroy_4_pressed() -> void:
	_on_destroy(Global.POIs.DESTROY4, %Destroy4, %RedParticles4, "res://Dialogue/37_rage3.tres", %Destroy2)


func _on_destroy(pos, object, particle, line, next_object):
	if object.get_child(0).emitting:
		%BentTree.z_index = 4
		if Global.player_POI_position != pos:
			if object == %Destroy0:
				Global.visit_clue.emit(Vector2(object.position.x +160, object.position.y + 260))
			else:
				Global.visit_clue.emit(Vector2(object.position.x +30, object.position.y + 260))
			await Global.arrived
			Global.player_POI_position = pos
		else:
			if not clues_interacted[object.name]:
				particle.emitting = false
				if "rock" in object.texture_normal.resource_path:
					$SFXAudio.stream = load("res://SFX/freesound_community-rock-destroy-6409.mp3")
					$SFXAudio.play()
					object.texture_normal = load("res://ArtAssets/rock_broken_.png")
				if "tree" in object.texture_normal.resource_path:
					$SFXAudio.stream = load("res://SFX/Kick.ogg")
					$SFXAudio.play()
					object.texture_normal = load("res://ArtAssets/tree_broken.png")
				await get_tree().create_timer(1).timeout
				dialogue = line
				DialogueManager.start_dialogue(dialogue, 0)
				await DialogueManager.dialogue_ended
				clues_interacted[object.name] = true
				if next_object != null:
					clues_discovered[next_object.name] = true
					next_object.get_child(0).emitting = true
				else:
					clues_interacted["Rage"] = true
					Global.speed = 200
					$RageLayer/AnimationPlayer.stop()
					$RageLayer.hide()
					%BentTree.z_index = 0

	
func cutscene_grief():
	$UILayer/MenuButton.hide()
	$StillImageLayer.show()
	%StillAnimationPlayer.play("show_slideshow")
	next_slide("res://ArtAssets/still1.png", "res://Dialogue/40_ending1.tres")
	await %StillAnimationPlayer.animation_finished
	next_slide("res://ArtAssets/still3.png", "res://Dialogue/41_ending2.tres")
	await %StillAnimationPlayer.animation_finished
	next_slide("res://ArtAssets/still5.png", "res://Dialogue/42_ending3.tres")
	await %StillAnimationPlayer.animation_finished
	next_slide("res://ArtAssets/still4.png", "res://Dialogue/43_ending4.tres")
	await %StillAnimationPlayer.animation_finished
	next_slide("res://ArtAssets/still6.png", "res://Dialogue/44_ending5.tres")
	await %StillAnimationPlayer.animation_finished
	next_slide(null, "res://Dialogue/45_ending6.tres")
	await %StillAnimationPlayer.animation_finished
	$StillImageLayer/Panel/Credits.show()
	var A = 0.0
	for n in 10:
		A += 0.1
		$StillImageLayer/Panel/Credits.self_modulate = Color(1.0, 1.0, 1.0, A)
	$StillImageLayer/Panel/SmokeParticles.emitting = false
	Global.clues_interacted["Credits"] = true
	show_menu_button()
	
func next_slide(path, line):
	if path != null:
		%StillImage.texture = load(path)
	else:
		%StillImage.texture = null
		if OS.has_feature("web"):
			$StillImageLayer/Panel/Workaround.show()
			$StillImageLayer/Panel/Workaround/AnimationPlayer.play("red smoke")
		else:
			$StillImageLayer/Panel/SmokeParticles.show()
			$StillImageLayer/Panel/SmokeParticles.emitting = true
	%StillAnimationPlayer.play("new_slide")
	dialogue = line
	DialogueManager.start_dialogue(dialogue, 0)
	await get_tree().create_timer(2).timeout
	%StillAnimationPlayer.pause()
	if DialogueManager.is_active:
		await DialogueManager.dialogue_ended
	%StillAnimationPlayer.play()


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
	
	
func play_soundtrack():
	var from_position = $MusicAudio.get_playback_position()
	$MusicAudio.stream = load(soundtrack)
	if $MusicAudio.stream.get_length() < from_position:
		$MusicAudio.play()
	else:
		$MusicAudio.play(from_position)
		
	
func darken_surroundings():
	$BackgroundLayers/Parallax2D/Sky.self_modulate = Color(0.5, 0.5, 0.5)
	$BackgroundLayers/Parallax2D2/Middle.self_modulate = Color(0.5, 0.5, 0.5)
	$Parallax2D3/Foreground.self_modulate = Color(0.5, 0.5, 0.5)


func lighten_surroundings():
	$BackgroundLayers/Parallax2D/Sky.self_modulate = Color(1.0, 1.0, 1.0)
	$BackgroundLayers/Parallax2D2/Middle.self_modulate = Color(1.0, 1.0, 1.0)
	$Parallax2D3/Foreground.self_modulate = Color(1.0, 1.0, 1.0)

	
func on_music_volume_changed():
	if Global.current_sense == Global.senses.HEAR:
		muffle_music()
	else:
		normalize_music()

func muffle_music():
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(Global.music_volume) - 7.153)
	#$MusicAudio.volume_db = linear_to_db(Global.music_volume) - 7.153
	$MusicAudio.pitch_scale = 0.81
	
	
func normalize_music():
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(Global.music_volume))
	#$MusicAudio.volume_db = linear_to_db(Global.music_volume)
	$MusicAudio.pitch_scale = 1.0


func show_scents():
	pass


func hide_scents():
	pass


func show_sounds():
	pass


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


func switch_scene():
	$SwitchScreen.show()
	var A = 0.0
	for n in 10:
		A += 0.1
		$SwitchScreen/Panel.self_modulate = Color(0.0, 0.0, 0.0, A)
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://environment_4.tscn")
