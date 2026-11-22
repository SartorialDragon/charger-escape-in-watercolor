extends State

class_name HorseHear

func enter():
	get_parent().get_parent().get_node("AnimatedSprite2D").play("hear")


func exit():
	pass
	
	
func update(_delta):
	pass

	
func physics_update(_delta):
	if get_parent().get_parent().velocity.x != 0:
		transitioned.emit(self, "trot")
	if not Global.clues_interacted["GetUp"]:
		transitioned.emit(self, "lie")
	if Global.current_sense == Global.senses.SEE:
		transitioned.emit(self, "idle")
	elif Global.current_sense == Global.senses.SMELL:
		transitioned.emit(self, "sniff")
	
