extends Control


var horse_offset
var hoofprint_spacing = 85
var last_print_position = Vector2(0,0)


@onready var player_horse: CharacterBody2D = %PlayerHorse


func _ready() -> void:
	Global.new_poi = null
	if get_tree().current_scene.name == "Environment1":
		print(get_tree().current_scene.name)


func _physics_process(_delta: float) -> void:
	if not Global.new_poi == null:
		if player_horse.find_child("AnimatedSprite2D").flip_h:
			if get_tree().current_scene.name == "Environment1":
				horse_offset = Vector2(player_horse.position.x + 550, player_horse.position.y + 50)
			else:
				horse_offset = Vector2(player_horse.position.x - 100, player_horse.position.y + 50)
		else:
			if get_tree().current_scene.name == "Environment1":
				horse_offset = Vector2(player_horse.position.x + 700, player_horse.position.y + 50)
			else:
				horse_offset = Vector2(player_horse.position.x + 50, player_horse.position.y + 50)
		var distance = horse_offset.distance_to(last_print_position)
		if distance > hoofprint_spacing:
			make_hoofprint()
			last_print_position = horse_offset
			

func make_hoofprint():
	var scene = load("res://hoofprint.tscn")
	var instance =  scene.instantiate()
	instance.position = horse_offset
	#instance.modulate = Color()
	instance.look_at(Global.new_poi.position)
	add_child(instance)
