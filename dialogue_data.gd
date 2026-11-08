# 

extends Resource
class_name DialogueData

@export var id: String
@export var lines: Array[DialogueLine] = []
@export var start_id: String

func get_line(line_id: String) -> DialogueLine:
	for line in lines:
		if line.id == line_id:
			return line
	return null
