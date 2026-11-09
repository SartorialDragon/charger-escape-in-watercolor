extends Control




func _on_look_pressed() -> void:
	Global.current_sense = Global.senses.SEE
	Global.sense_mode_changed.emit()

func _on_hear_pressed() -> void:
	Global.current_sense = Global.senses.HEAR
	Global.sense_mode_changed.emit()
	

func _on_smell_pressed() -> void:
	Global.current_sense = Global.senses.SMELL
	Global.sense_mode_changed.emit()
