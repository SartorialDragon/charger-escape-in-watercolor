extends Node


signal visit_clue
signal arrived

var current_state: State

enum senses {SEE, HEAR, SMELL}
var current_sense: senses = 0


# this means the clue is *visible* in the right sense mode unless it's not been discovered!
var clues_discovered = { # key needs to be identical with node name
	"Interactable Item 0" : true,
	"Interactable Item 1" : true,
	"Interactable Item 2" : false,
	"Interactable Item 3" : true,
	"Interactable Item 4" : false,
	"Interactable Item 5" : true,
}

# this means it has been clicked
var clues_interacted = {
	"Interactable 0" : false,
	"Interactable 1" : false,
	"Interactable 2" : false,
	"Interactable 3" : false,
	"Interactable 4" : false,
	"Interactable 5" : false,
}
