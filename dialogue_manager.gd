extends Node


# Tutorial: https://codingquests.io/blog/godot-4-dialogue-system-tutorial

signal dialogue_started(file: NodePath, type: int)
signal line_displayed(line: DialogueLine)
signal dialogue_ended
signal error_dialogue_started(file: NodePath, type: int)


var current_data: DialogueData
var current_line: DialogueLine
var is_active: bool = false

func start_dialogue(file: NodePath, type: int) -> void:
	if ResourceLoader.exists(file):
		current_data = ResourceLoader.load(file)
	else:
		current_data = ResourceLoader.load("res://Dialogue/00_dialogue_missing.tres")
	is_active = true
	match type:
		0:
			dialogue_started.emit(current_data)
		1:
			error_dialogue_started.emit(current_data)
	_show_line(current_data.start_id)
	

func _show_line(line_id: String) -> void:
	current_line = current_data.get_line(line_id)
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
	dialogue_ended.emit(current_data)
