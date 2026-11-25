extends Node

signal game_started
signal close_menu
signal visit_clue
signal arrived
signal sense_mode_changed

signal hint_needed
signal hint_done
signal got_up

signal master_volume_changed
signal voice_volume_changed
signal music_volume_changed
signal sfx_volume_changed


var master_volume: float = 1.0
var music_volume: float = 1.0
var voice_volume: float = 1.0
var sfx_volume: float = 1.0

var speed = 330

@onready var current_state: State
var player_start_position: Vector2 = Vector2(200,200)
enum POIs {START, ROCKCLUSTER_0, ROCKCLUSTER_1, ROCKCLUSTER_2, ROCKCLUSTER_3, STALLIONSCENT, ROCKSLIDE, TREE_0, TREES, BUCKET, STREAM, SCENT_0, SCENT_1, SOUND_0, SOFTSPOT, HOOFPRINTS, SPRING, DESTROY0, DESTROY1, DESTROY2, DESTROY3, DESTROY4, }
var player_POI_position: POIs = POIs.START


enum senses {SEE, HEAR, SMELL}
var current_sense: senses = senses.HEAR


# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
	"GetUp" : false,
	"Echo" : false,
	"Sight" : false,
	"Hearing" : false,
	"Scent" : false,
	"Credits" : false,
}

# this means it has been clicked
var clues_interacted = {
	"GetUp" : false,
	"Echo" : false,
	"Sight" : false,
	"Hearing" : false,
	"Scent" : false,
	"Credits" : false,
}


func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
