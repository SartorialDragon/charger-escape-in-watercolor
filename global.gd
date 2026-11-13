extends Node

signal game_started
signal visit_clue
signal arrived
signal sense_mode_changed

signal hint_needed
signal hint_done
signal got_up


var current_state: State
var player_start_position: Vector2 = Vector2(200,200)
enum POIs {START, ROCKCLUSTER_0, ROCKCLUSTER_1, ROCKCLUSTER_2, ROCKCLUSTER_3, STALLIONSCENT, ROCKSLIDE, TREE_0, TREES, BUCKET, STREAM}
var player_POI_position: POIs = POIs.START


enum senses {SEE, HEAR, SMELL}
var current_sense: senses = senses.HEAR


# these have been moved to the environment script for environment1, they don't actually need to be global, but only for the current environment's scene.

# this means the clue has been discovered in sense mode or through solving other clues!
var clues_discovered = { # key needs to be identical with node name
	"Interactable Item 0" : false,
	"Interactable Item 1" : false,
	"Interactable Item 2" : false,
	"Interactable Item 3" : false,
	"Interactable Item 4" : false,
	"Interactable Item 5" : false,
}

# this means it has been clicked
var clues_interacted = {
	"Interactable 0" : false,
	"Interactable 1" : false,
	"Interactable 2" : false,
	"Interactable 3" : false,
	"Interactable 4" : false,
	"Interactable 5" : false,
	"GetUp" : false,
	"Echo" : false,
	"Sight" : false,
	"Hearing" : false,
	"Scent" : false,
}
