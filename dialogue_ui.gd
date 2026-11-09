extends CanvasLayer

@onready var clue_dialogue: CanvasLayer = self
@onready var memory_panel: TextureRect = $Panel/DialoguePanel/MemoryPanel
@onready var speaker_label: Label = %SpeakerLabel
@onready var text_label: Label = %TextLabel

func _ready() -> void:
	clue_dialogue.visible = false
	DialogueManager.dialogue_started.connect(_on_started)
	DialogueManager.line_displayed.connect(_on_line)
	DialogueManager.dialogue_ended.connect(_on_ended)


func _on_started(_data: DialogueData) -> void:
	clue_dialogue.visible = true
	%AdvanceDialogueButton.grab_focus()


func _on_line(line: DialogueLine) -> void:
	print("on line received	: ", line.id)
	memory_panel.texture = line.image
	speaker_label.text = line.speaker
	text_label.text = line.text
	$AudioStreamPlayer.stream = line.vc_file
	$AudioStreamPlayer.play()
   

func _on_ended() -> void:
	clue_dialogue.visible = false

# not needed because the UI button now grabs the focus anyway and this would double the input
# might be needed because if the sense buttons grab focus, it's a problem BUG
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("interact") and DialogueManager.is_active:
		#DialogueManager.advance()


func _on_advance_dialogue_button_pressed() -> void:
	if DialogueManager.is_active:
		DialogueManager.advance()
