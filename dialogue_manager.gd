extends Node


# Tutorial: https://codingquests.io/blog/godot-4-dialogue-system-tutorial

signal dialogue_started(data: DialogueData)
signal line_displayed(line: DialogueLine)
signal dialogue_ended

var current_data: DialogueData
var current_line: DialogueLine
var is_active: bool = false

func start_dialogue(data: DialogueData) -> void:
	current_data = data
	is_active = true
	dialogue_started.emit(data)
	_show_line(data.start_id)
	

func _show_line(line_id: String) -> void:
	current_line = current_data.get_line(line_id)
	#print(current_line)
	if current_line == null:
		end_dialogue()
		return
	line_displayed.emit(current_line)
		

func advance() -> void:
	# Called when player clicks to continue (no choices)
	if current_line and current_line.next_id != "":
		_show_line(current_line.next_id)
	else:
		end_dialogue()
		
		
func end_dialogue() -> void:
	is_active = false
	current_data = null
	current_line = null
	dialogue_ended.emit()
