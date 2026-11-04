extends CharacterBody2D

var speed = 300

var click_position = Vector2()
var target_position = Vector2()

func _ready():
	Global.interactable0.connect(move_to_0)
	Global.interactable1.connect(move_to_1)
	Global.interactable2.connect(move_to_2)
	Global.interactable3.connect(move_to_3)
	position = Vector2(900, 500)
	click_position = position
	
func _physics_process(delta: float) -> void:
	change_position()
	
	
func move_to_0(pos):
	if position.x < pos.x:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
	click_position = pos
	
	
func move_to_1(pos):
	if position.x < pos.x:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
	click_position = pos
	
	
func move_to_2(pos):
	if position.x < pos.x:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
	click_position = pos
	
func move_to_3(pos):
	if position.x < pos.x:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
	click_position = pos

	
func change_position():
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * speed
		move_and_slide()
	else:
		velocity = Vector2(0, 0)
