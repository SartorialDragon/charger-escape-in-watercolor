extends State

class_name HorseLie

func enter():
	get_parent().get_parent().get_node("AnimatedSprite2D").play("lie")
	
	
func exit():
	Global.got_up.emit()
	
	
func update(_delta):
	pass
	
	
func physics_update(_delta):
	if Global.clues_interacted["GetUp"]:
		transitioned.emit(self, "idle")
