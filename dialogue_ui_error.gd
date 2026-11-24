extends CanvasLayer

@onready var error_dialogue: CanvasLayer = self
@onready var speaker_label: Label = %SpeakerLabel
@onready var text_label: Label = %TextLabel
@onready var va_audio: AudioStreamPlayer = %VAAudio


func _ready() -> void:
	error_dialogue.visible = false
	DialogueManager.error_dialogue_started.connect(_on_error_started)
	DialogueManager.dialogue_started.connect(_on_ended)
	DialogueManager.line_displayed.connect(_on_line)
	Global.voice_volume_changed.connect(_on_voice_volume_changed)
	

func _on_error_started(_data: DialogueData) -> void:
	error_dialogue.visible = true
	

func _on_line(line: DialogueLine) -> void:
	speaker_label.text = line.speaker
	text_label.text = line.text
	if Global.voice_volume <= 0.0:
		return
	va_audio.stream = line.vc_file
	va_audio.play()
	if line.vc_file != null:
		await va_audio.finished
	else:
		await get_tree().create_timer(1.5).timeout
	_on_ended(DialogueManager.current_data)
   

func _on_ended(current_data) -> void:
	error_dialogue.visible = false
		
func _on_voice_volume_changed():
	va_audio.volume_db = 30 * (Global.voice_volume - 1)
