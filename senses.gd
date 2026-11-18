extends Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("sight"):
		_on_look_pressed()
	elif event.is_action_pressed("hearing"):
		_on_hear_pressed()
	elif event.is_action_pressed("scent"):
		_on_smell_pressed()


#func _process(delta: float) -> void:
	#if $Look.is_hovered():
		#$Look2.self_modulate = Color(0.49, 0.49, 1.0)
	#else:
		#$Look2.self_modulate = Color(0.0, 0.0, 0.0)
	#if $Hear.is_hovered():
		#$Hear2.self_modulate = Color(1.0, 0.933, 0.49)
	#else:
		#$Hear2.self_modulate = Color(0.0, 0.0, 0.0)
	#if $Smell.is_hovered():
		#$Smell2.self_modulate = Color(0.678, 1.0, 0.663)
	#else:
		#$Smell2.self_modulate = Color(0.0, 0.0, 0.0)



func _on_look_pressed() -> void:
	Global.current_sense = Global.senses.SEE
	if not Global.clues_interacted["GetUp"]:
		Global.got_up.emit()
		Global.clues_interacted["GetUp"] = true
	Global.hint_done.emit("Echo")
	Global.hint_done.emit("Sight")
	Global.sense_mode_changed.emit()
	hide()


func _on_hear_pressed() -> void:
	Global.current_sense = Global.senses.HEAR
	Global.hint_done.emit("Echo")
	Global.hint_done.emit("Hearing")
	Global.sense_mode_changed.emit()
	hide()
	

func _on_smell_pressed() -> void:
	Global.current_sense = Global.senses.SMELL
	Global.hint_done.emit("Echo")
	Global.hint_done.emit("Scent")
	Global.sense_mode_changed.emit()
	hide()
