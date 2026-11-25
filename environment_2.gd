extends Control

var dialogue: NodePath

var cursor_default = load("res://ArtAssets/Cursor_Sepia.png")
var cursor_POI = load("res://ArtAssets/Cursor_Brown.png")

var visible_clues: Array = []
var clues_on_screen: Array = []

@onready var player_horse: CharacterBody2D = %PlayerHorse

var soundtrack: String

var horse_offset
var hoofprint_spacing = 85
var last_print_position = Vector2(0,0)
var new_poi: Node

# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
	"Tree0" : false,
	"Tree0Mane" : false,
	"Bucket" : false,
	"Stream" : false,
	"Tree1" : false,
	"Tree2" : false,
	"Tree3" : false,
	"Smoldering" : false,
}

# this means it has been clicked
var clues_interacted = {
	"Tree0" : false,
	"Tree0Mane" : false,
	"Bucket" : false,
	"Stream" : false,
	"Tree1" : false,
	"Tree2" : false,
	"Tree3" : false,
	"Smoldering" : false,
}


func _ready():
	Input.set_custom_mouse_cursor(cursor_default)
	Input.set_custom_mouse_cursor(cursor_POI, Input.CURSOR_POINTING_HAND)
	Global.player_start_position = Vector2(400, 750)
	Global.sense_mode_changed.connect(sense_change)
	Global.close_menu.connect(show_menu_button)
	#Global.music_volume_changed.connect(on_music_volume_changed)
	Global.clues_interacted["GetUp"] = true
	Global.current_sense = Global.senses.SEE
	_on_see_button_pressed()
	await get_tree().create_timer(1).timeout
	dialogue = "res://Dialogue/23_E2 start.tres"
	DialogueManager.start_dialogue(dialogue, 0)
	#await DialogueManager.dialogue_ended
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") and Global.clues_interacted["GetUp"]:
		_on_menu_button_pressed()


func _physics_process(_delta: float) -> void:
	if not new_poi == null:
		if %PlayerHorse.find_child("AnimatedSprite2D").flip_h:
		#if player_horse.position.x < new_poi.position.x:
			horse_offset = Vector2(player_horse.position.x - 100, player_horse.position.y + 50)
		else:
			horse_offset = Vector2(player_horse.position.x + 50, player_horse.position.y + 50)
		var distance = horse_offset.distance_to(last_print_position)
		if distance > hoofprint_spacing:
			make_hoofprint(new_poi)
			last_print_position = horse_offset

	if clues_interacted["Bucket"] == true and clues_interacted["Smoldering"] == false:
		%Bucket.position = Vector2($BackgroundLayers/Parallax2D2/PlayerHorse.position.x -170, $BackgroundLayers/Parallax2D2/PlayerHorse.position.y - 170)


func make_hoofprint(poi):
	var scene = load("res://hoofprint.tscn")
	var instance =  scene.instantiate()
	instance.position = horse_offset
	#instance.get_child(0).flip_v = !instance.get_child(0).flip_v
	instance.look_at(poi.position)
	$BackgroundLayers/Parallax2D2/Hooves.add_child(instance)



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


	
func _on_tree_0_pressed() -> void:
	if Global.player_POI_position != Global.POIs.TREE_0:
		new_poi = %Tree0
		Global.visit_clue.emit(Vector2(%Tree0.position.x + 80, %Tree0.position.y + 260))
		await Global.arrived
		Global.player_POI_position = Global.POIs.TREE_0
	else:
		if Global.current_sense == Global.senses.SEE:
			dialogue = "res://Dialogue/08_can't_see.tres"
			DialogueManager.start_dialogue(dialogue, 1)
		elif Global.current_sense == Global.senses.HEAR:
			dialogue = "res://Dialogue/13_can't_hear.tres"
			DialogueManager.start_dialogue(dialogue, 1)
		elif Global.current_sense == Global.senses.SMELL:
			%Tree0Mane.visible = true
			clues_interacted["Tree0"] = true


func _on_mane_hair_pressed() -> void:
	if Global.player_POI_position != Global.POIs.TREE_0:
		new_poi = %Tree0Mane
		Global.visit_clue.emit(Vector2(%Tree0Mane.position.x + 80, %Tree0Mane.position.y + 260))
		await Global.arrived
		Global.player_POI_position = Global.POIs.TREE_0
	else:
		if Global.current_sense == Global.senses.SEE:
			pass
		elif Global.current_sense == Global.senses.HEAR:
			pass
		elif Global.current_sense == Global.senses.SMELL:
			%Tree0Mane.add_to_group("on_screen")
			dialogue = "res://Dialogue/09_his_mane.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			await DialogueManager.dialogue_ended
			if not clues_interacted["Tree0Mane"]:
				if OS.has_feature("web"):
					$BackgroundLayers/Parallax2D2/Workaround.show()
					$BackgroundLayers/Parallax2D2/Workaround/AnimationPlayer.play("grey smoke")
					$BackgroundLayers/Parallax2D2/Workaround2.show()
					$BackgroundLayers/Parallax2D2/Workaround2/AnimationPlayer.play("grey smoke")
				else:
					$BackgroundLayers/Parallax2D2/SmokeParticles.emitting = true
				# camera moves
				for n in 50:
					$Camera2D.position.x += 8
					await get_tree().create_timer(0.001).timeout
				new_poi = %Tree2 # approximately
				Global.visit_clue.emit(Vector2(2600, 750))
				for n in 250:
					$Camera2D.position.x += 8
					await get_tree().create_timer(0.001).timeout
				%Bucket.add_to_group("on_screen")
				clues_interacted["Tree0Mane"] = true
				if Global.current_state.name == "Trot":
					await Global.arrived
				dialogue = "res://Dialogue/25_still_burning.tres"
				DialogueManager.start_dialogue(dialogue, 0)
				%Stream.disabled = false
				clues_on_screen = get_tree().get_nodes_in_group("on_screen")
				%Tree0.remove_from_group("on_screen")
				%Tree0Mane.remove_from_group("on_screen")
				%Stream.add_to_group("on_screen")
				%Tree1.add_to_group("on_screen")
				%Tree2.add_to_group("on_screen")
				%Tree3.add_to_group("on_screen")
				


func _on_bucket_pressed() -> void:
	if not clues_interacted["Bucket"]:
		if Global.player_POI_position != Global.POIs.BUCKET:
			new_poi = %Bucket
			Global.visit_clue.emit(Vector2(%Bucket.position.x + 50, %Bucket.position.y + 100))
			await Global.arrived
			Global.player_POI_position = Global.POIs.BUCKET
		else:
			# pick up bucket
			dialogue = "res://Dialogue/26_human_trash.tres"
			DialogueManager.start_dialogue(dialogue, 0)
			clues_interacted["Bucket"] = true
			%Bucket.rotation = 0.0


func _on_stream_pressed() -> void:
	if Global.player_POI_position != Global.POIs.STREAM:
		new_poi = %Stream
		Global.visit_clue.emit(Vector2(%Stream.position.x + 600, %Stream.position.y + 100))
		await Global.arrived
		Global.player_POI_position = Global.POIs.STREAM
	else:
		if clues_interacted["Bucket"]:
			$SFXAudio.stream = load("res://SFX/421184__inspectorj__water-pouring-a.ogg")
			$SFXAudio.play()
			%Bucket.texture_normal = load("res://ArtAssets/bucket_full.png")


func _on_tree_1_pressed() -> void:
	_on_tree_pressed(%Tree1, %TreeParticles1)
	
func _on_tree_2_pressed() -> void:
	_on_tree_pressed(%Tree2, %TreeParticles2)

func _on_tree_3_pressed() -> void:
	_on_tree_pressed(%Tree3, %TreeParticles3)
	

func _on_tree_pressed(tree, particle):
	if Global.player_POI_position != Global.POIs.TREES:
		new_poi = tree
		Global.visit_clue.emit(Vector2(tree.position.x - 40, tree.position.y + 150))
		await Global.arrived
		Global.player_POI_position = Global.POIs.TREES
	elif clues_interacted["Smoldering"]:
		if tree.is_in_group("on_screen"):
			move_through_trees()
	else:
		if not clues_interacted["Bucket"] or not %Bucket.texture_normal == load("res://ArtAssets/bucket_full.png"):
			dialogue = "res://Dialogue/12_can't_pass.tres"
			DialogueManager.start_dialogue(dialogue, 1)
		else:
			if not %Bucket.texture_normal == load("res://ArtAssets/bucket_full.png"):
				pass
			else:
				if not clues_interacted[tree.name]:
					$SFXAudio.stream = load("res://SFX/666290__ekrcoaster__water-steaming-on-hot-surface-1.ogg")
					$SFXAudio.play()
					%Bucket.texture_normal = load("res://ArtAssets/bucket_empty.png")
					particle.emitting = false
					tree.texture_normal = load("res://ArtAssets/e2 smoldering_off.png")
					clues_interacted[tree.name] = true
					clues_interacted["Smoldering"] = true
					for n in 3:
						if clues_interacted["Tree"+str(n+1)] == false:
							clues_interacted["Smoldering"] = false
		

func move_through_trees():
	if OS.has_feature("web"):
		$BackgroundLayers/Parallax2D2/Workaround2.show()
		$BackgroundLayers/Parallax2D2/Workaround2/AnimationPlayer.play("grey smoke")
	else:
		$BackgroundLayers/Parallax2D2/SmokeParticles2.emitting = true
	dialogue = "res://Dialogue/27_pass_through_trees.tres"
	DialogueManager.start_dialogue(dialogue, 0)
	await DialogueManager.dialogue_ended
	%BucketAnimationPlayer.play("fall")
	for n in 50:
		$Camera2D.position.x += 8
		await get_tree().create_timer(0.001).timeout
	new_poi = %PlayerHorse
	Global.visit_clue.emit(Vector2(4500, 800))
	for n in 260:
		$Camera2D.position.x += 8
		await get_tree().create_timer(0.001).timeout
	$BackgroundLayers/Parallax2D2/SmokeParticles.emitting = false
	if Global.current_state.name == "Trot":
		await Global.arrived
	if OS.has_feature("web"):
		$BackgroundLayers/Parallax2D2/Workaround.hide()
		$BackgroundLayers/Parallax2D2/Workaround/AnimationPlayer.stop()
	else:
		$BackgroundLayers/Parallax2D2/SmokeParticles.emitting = false
	new_poi = %PlayerHorse
	Global.visit_clue.emit(Vector2(player_horse.position.x + 1500, player_horse.position.y + 0))
	clues_on_screen = get_tree().get_nodes_in_group("on_screen")
	for n in clues_on_screen:
		n.remove_from_group("on_screen")
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
	darken_surroundings()
	normalize_music()
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
	$BackgroundLayers/Parallax2D/Sky.modulate = Color(0.5, 0.5, 0.5)
	$BackgroundLayers/Parallax2D2/Middle.modulate = Color(0.5, 0.5, 0.5)
	$Parallax2D3/Foreground.modulate = Color(0.5, 0.5, 0.5)
	%Tree0.self_modulate = Color(0.5, 0.5, 0.5)
	%Tree0Mane.self_modulate = Color(0.5, 0.5, 0.5)
	%Bucket.modulate = Color(0.5, 0.5, 0.5)
	%Stream.modulate = Color(0.5, 0.5, 0.5)
	%Tree1.modulate = Color(0.5, 0.5, 0.5)
	%Tree2.modulate = Color(0.5, 0.5, 0.5)
	%Tree3.modulate = Color(0.5, 0.5, 0.5)
	$BackgroundLayers/Parallax2D2/Hooves.modulate = Color(0.5, 0.5, 0.5)


func lighten_surroundings():
	$BackgroundLayers/Parallax2D/Sky.modulate = Color(1.0, 1.0, 1.0)
	$BackgroundLayers/Parallax2D2/Middle.modulate = Color(1.0, 1.0, 1.0)
	$Parallax2D3/Foreground.modulate = Color(1.0, 1.0, 1.0)
	%Tree0.self_modulate = Color(1.0, 1.0, 1.0)
	%Tree0Mane.self_modulate = Color(1.0, 1.0, 1.0)
	%Bucket.modulate = Color(1.0, 1.0, 1.0)
	%Stream.modulate = Color(1.0, 1.0, 1.0)
	%Tree1.modulate = Color(1.0, 1.0, 1.0)
	%Tree2.modulate = Color(1.0, 1.0, 1.0)
	%Tree3.modulate = Color(1.0, 1.0, 1.0)
	$BackgroundLayers/Parallax2D2/Hooves.modulate = Color(1.0, 1.0, 1.0)
	
	
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
	%Tree0Mane.self_modulate = Color(1.0, 1.0, 1.0)


func show_scents():
	if %Tree0.is_in_group("on_screen"):
		%TreeParticles0.visible = true
		%TreeParticles0.emitting = true
		if clues_discovered["Tree0Mane"]:
			%TreeParticlesMane.visible = true
			%TreeParticlesMane.emitting = true
		# actually this should only switch on/of scent marking particles, not the smoke itself
			
	

func hide_scents():
	%TreeParticles0.visible = false
	%TreeParticles0.emitting = false
	%TreeParticlesMane.visible = false
	%TreeParticlesMane.emitting = false

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
