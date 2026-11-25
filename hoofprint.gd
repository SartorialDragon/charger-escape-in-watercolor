extends Node2D


func _ready() -> void:
	await get_tree().create_timer(7).timeout
	queue_free()
