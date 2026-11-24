extends CanvasLayer

@onready var clue_dialogue: CanvasLayer = self
@onready var memory_panel: TextureRect = $Panel/DialoguePanel/MemoryPanel
@onready var speaker_label: Label = %SpeakerLabel
@onready var text_label: Label = %TextLabel
@onready var va_audio: AudioStreamPlayer = %VAAudio



func _ready() -> void:
	clue_dialogue.visible = false
	DialogueManager.dialogue_started.connect(_on_started)
	DialogueManager.error_dialogue_started.connect(_on_ended)
	DialogueManager.line_displayed.connect(_on_line)
	DialogueManager.dialogue_ended.connect(_on_ended)
	Global.voice_volume_changed.connect(_on_voice_volume_changed)


func _on_started(_data: DialogueData) -> void:
	clue_dialogue.visible = true
	%AdvanceDialogueButton.grab_focus()


func _on_line(line: DialogueLine) -> void:
	memory_panel.texture = line.image
	speaker_label.text = line.speaker
	text_label.text = line.text
	if Global.voice_volume > 0:
		va_audio.stream = line.vc_file
		va_audio.play()
   

func _on_ended(current_data) -> void:
	clue_dialogue.visible = false
	#va_audio.stop()

# not needed because the UI button now grabs the focus anyway and this would double the input
# might be needed because if the sense buttons grab focus, it's a problem BUG
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("interact") and DialogueManager.is_active:
		#DialogueManager.advance()


func _on_advance_dialogue_button_pressed() -> void:
	if DialogueManager.is_active:
		DialogueManager.advance()
		
func _on_voice_volume_changed():
	va_audio.volume_db = linear_to_db(Global.voice_volume)
