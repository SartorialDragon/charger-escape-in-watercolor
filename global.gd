extends Node


signal interactable0
signal interactable1
signal interactable2
signal interactable3
signal arrived

var current_state: State

var clues_found = {
	"Interactable 0" : false,
	"Interactable 1" : false,
	"Interactable 2" : false,
	"Interactable 3" : false,
	"Interactable 4" : false,
}
