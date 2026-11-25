extends Control


var horse_offset
var hoofprint_spacing = 85
var last_print_position = Vector2(0,0)


@onready var player_horse: CharacterBody2D = %PlayerHorse


func _ready() -> void:
	Global.new_poi = null


func _physics_process(_delta: float) -> void:
	if not Global.new_poi == null:
		if player_horse.find_child("AnimatedSprite2D").flip_h:
			#horse_offset = Vector2(player_horse.position.x - 50, player_horse.position.y + 50)
			horse_offset = Vector2(player_horse.global_position.x - 50, player_horse.global_position.y + 50)
		else:
			#horse_offset = Vector2(player_horse.position.x + 0, player_horse.position.y + 50)
			horse_offset = Vector2(player_horse.global_position.x - 0, player_horse.global_position.y + 50)
		var distance = horse_offset.distance_to(last_print_position)
		if distance > hoofprint_spacing:
			make_hoofprint()
			last_print_position = horse_offset
			

func make_hoofprint():
	var scene = load("res://hoofprint.tscn")
	var instance =  scene.instantiate()
	instance.position = horse_offset
	instance.look_at(Global.new_poi.position)
	add_child(instance)
