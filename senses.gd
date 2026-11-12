extends Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("sight"):
		_on_look_pressed()
	elif event.is_action_pressed("hearing"):
		_on_hear_pressed()
	elif event.is_action_pressed("scent"):
		_on_smell_pressed()



func _on_look_pressed() -> void:
	Global.current_sense = Global.senses.SEE
	Global.hint_done.emit("Echo")
	Global.hint_done.emit("Sight")
	Global.sense_mode_changed.emit()

func _on_hear_pressed() -> void:
	Global.current_sense = Global.senses.HEAR
	Global.hint_done.emit("Echo")
	Global.hint_done.emit("Hearing")
	Global.sense_mode_changed.emit()
	

func _on_smell_pressed() -> void:
	Global.current_sense = Global.senses.SMELL
	Global.hint_done.emit("Echo")
	Global.hint_done.emit("Scent")
	Global.sense_mode_changed.emit()
