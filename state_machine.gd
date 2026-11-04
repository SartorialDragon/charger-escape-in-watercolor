extends Node

@export var initial_state: State
var states: Dictionary = {}

#Tutorial: https://www.youtube.com/watch?v=ow_Lum-Agbs

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	if initial_state:
		initial_state.enter()
		Global.current_state = initial_state


func _process(delta: float) -> void:
	if Global.current_state:
		Global.current_state.update(delta)
	
	
func _physics_process(delta: float) -> void:
	if Global.current_state:
		Global.current_state.physics_update(delta)
		
		
func on_child_transition(state, new_state_name):
	if state != Global.current_state:
		return
	var new_state = states.get(new_state_name.to_lower())
	if Global.current_state:
		Global.current_state.exit()
	new_state.enter()
	Global.current_state = new_state
	
	
	
