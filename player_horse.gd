extends CharacterBody2D

var speed = 300

var click_position = Vector2()
var target_position = Vector2()

func _ready():
	Global.visit_clue.connect(move_to)
	Global.hint_needed.connect(give_hint)
	Global.hint_done.connect(hide_hint)
	await get_tree().create_timer(0.01).timeout # this could use refactoring, without timer the variable is not set right yet
	position = Global.player_start_position
	click_position = position
	
	
func _physics_process(delta: float) -> void:
	change_position()
	
	
func give_hint(pos):
	match pos:
		"Echo":
			$HintParticles.position = Vector2(-13, -11)
		"Sight":
			$HintParticles.position = Vector2(-64, -111)
		"Scent":
			$HintParticles.position = Vector2(25, -111)
		"Hearing":
			$HintParticles.position = Vector2(-17, -128)
		_:
			$HintParticles.position = Vector2(0, 0)
	$HintParticles.emitting = true
	
	
func hide_hint(pos):
	Global.clues_discovered[pos] = true
	$HintParticles.emitting = false
	
	
func move_to(pos):
	if position.x < pos.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	click_position = pos
	

	
func change_position():
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * speed
		move_and_slide()
	else:
		velocity = Vector2(0, 0)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("click")
		$Senses.show()
		await get_tree().create_timer(3).timeout
		$Senses.hide()



func _on_texture_button_pressed() -> void:
	$Senses.show()
	await get_tree().create_timer(2).timeout
	if not Global.clues_interacted["Sight"] and $Senses.visible:
		give_hint("Sight")
		Global.clues_interacted["Sight"] = true
	else:	
		Global.hint_done.emit("Echo")
