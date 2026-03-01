extends Node

func _ready():
	GameManager.reset()
	call_deferred("_load_street")

func _load_street():
	get_tree().change_scene_to_file("res://scenes/levels/street.tscn")
