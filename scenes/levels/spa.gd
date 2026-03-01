extends Node3D

func _ready():
	AudioManager.play_music("res://assets/audio/music/bawitdaba.mp3", -5.0)
	GameManager.milk_collected.connect(_on_milk_collected)

func _on_milk_collected():
	pass
