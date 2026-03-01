extends Node3D

var milk_scene = preload("res://scenes/levels/milk_pickup.tscn") if FileAccess.file_exists("res://scenes/levels/milk_pickup.tscn") else null

func _ready():
	AudioManager.play_music("res://assets/audio/music/bawitdaba.mp3", -5.0)
	GameManager.milk_collected.connect(_on_milk_collected)

func _on_milk_collected():
	pass
