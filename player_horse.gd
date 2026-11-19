extends CharacterBody2D

@onready var navi: NavigationAgent2D = $NavigationAgent2D


var speed = 300

var click_position = Vector2()
var target_position = Vector2()


func _ready():
	Global.visit_clue.connect(move_to)
	Global.hint_needed.connect(give_hint)
	Global.hint_done.connect(hide_hint)
	navi.navigation_finished.connect(when_arrived)
	await get_tree().create_timer(0.01).timeout # this could use refactoring, without timer the variable is not set right yet
	position = Global.player_start_position
	click_position = position
	
	
func _physics_process(delta: float) -> void:
	if not Global.navigation_mode:
		change_position()
	else:
		#navigate(delta)
		move_it()


func move_it():
	if position.distance_to(navi.target_position) > 50:
		var dir = to_local(navi.get_next_path_position()).normalized()
		velocity = dir * speed
		move_and_slide()


func when_arrived():
	velocity = Vector2(0.0, 0.0)
	Global.arrived.emit()
	print("it's finished, velocity: ", velocity)

	
	
#func _input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("click"):
		#navi.target_position = get_global_mouse_position()
		#print("mouse position: ", get_global_mouse_position())
	
	
func navigate(delta):
	if navi.is_navigation_finished():
		return
	#if position.distance_to(navi.target_position) > 50:
	var next_path_position: Vector2 = to_local(navi.get_next_path_position()).normalized()
	velocity = next_path_position * speed * delta
	#velocity = (global_position.direction_to(next_path_position) * speed)
	#position += velocity * delta
	move_and_slide()
	#else:
		#velocity = Vector2(0, 0)
	

	
	
func move_to(pos):
	if position.x < pos.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	navi.target_position = pos
	click_position = pos
	#print(click_position)
	#print(navi.target_position)
	

	
func change_position():
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * speed
		move_and_slide()
	else:
		velocity = Vector2(0, 0)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		#print("click")
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


func give_hint(pos):
	match pos:
		"Echo":
			$HintParticles.position = Vector2(-13, -11)
		"Sight":
			$HintParticles.position = Vector2(-64, -70)
		"Scent":
			$HintParticles.position = Vector2(25, -111)
		"Hearing":
			$HintParticles.position = Vector2(-17, -128)
		_:
			$HintParticles.position = Vector2(0, 0)
	$HintParticles.emitting = true
	
	
func hide_hint(pos):
	#print("pos: ", pos, " hidden")
	Global.clues_discovered[pos] = true
	$HintParticles.emitting = false
