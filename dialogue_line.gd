# this sets up how a resource file for DialogueLine is structured

extends Resource
class_name DialogueLine

@export var id: String
@export var speaker: String
@export var image: Texture2D
@export var text: String
@export var vc_file: AudioStream
@export var next_id: String = ""  # Auto-advance to this line (if no choices)
@export var conditions: Array[String] = []  # Conditions that must be true
