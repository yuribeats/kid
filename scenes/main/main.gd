extends Node

func _ready():
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/levels/street.tscn")
