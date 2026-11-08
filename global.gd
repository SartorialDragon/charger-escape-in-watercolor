extends Node


signal visit_clue
signal arrived

var current_state: State

var clues_found = {
	"Interactable 0" : false,
	"Interactable 1" : false,
	"Interactable 2" : false,
	"Interactable 3" : false,
	"Interactable 4" : false,
}
