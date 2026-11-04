extends State

class_name HorseIdle

func enter():
	get_parent().get_parent().get_node("AnimatedSprite2D").play("idle")
	#bored_timer() # this is only needed if idle animation variation gets implemented!
	

func bored_timer():
	await get_tree().create_timer(randi_range(2,5)).timeout
	if Global.current_state == self:
		play_random_idle()
			
	
	
func exit():
	pass
	
	
func update(_delta):
	pass

	
func physics_update(_delta):
	if get_parent().get_parent().velocity.x != 0:
		transitioned.emit(self, "trot")
	
	
func play_random_idle():
	var idle_animations = ["idle_ears", "idle_tailswish"]
	get_parent().get_parent().get_node("AnimatedSprite2D").play(idle_animations[randi_range(0, idle_animations.size()-1)])
	await get_parent().get_parent().get_node("AnimatedSprite2D").animation_finished
	get_parent().get_parent().get_node("AnimatedSprite2D").play("idle")
	bored_timer()
