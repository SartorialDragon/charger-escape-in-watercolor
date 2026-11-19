extends State

class_name HorseTrot

func enter():
	get_parent().get_parent().get_node("AnimatedSprite2D").play("trot")
	print("entered trot state")
	
func exit():
	Global.arrived.emit()
	
	
	
func update(_delta):
	pass
	
	
func physics_update(_delta):
	if get_parent().get_parent().velocity.x == 0.0:
		transitioned.emit(self, "idle")
		print("transitioned emitted")
	#else:
		#print("velocity is: ", get_parent().get_parent().velocity.x)
