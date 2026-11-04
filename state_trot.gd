extends State

class_name HorseTrot

func enter():
	print("trot")
	get_parent().get_parent().get_node("AnimatedSprite2D").play("trot")
	
func exit():
	print("trot stop")
	Global.arrived.emit()
	
	
func update(_delta):
	pass
	
	
func physics_update(_delta):
	if get_parent().get_parent().velocity.x == 0:
		transitioned.emit(self, "idle")
