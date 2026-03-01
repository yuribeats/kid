extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)

func play_music(path: String, volume_db: float = -5.0):
	var stream = load(path)
	if stream:
		music_player.stream = stream
		music_player.volume_db = volume_db
		music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(path: String, volume_db: float = 0.0):
	var stream = load(path)
	if stream:
		sfx_player.stream = stream
		sfx_player.volume_db = volume_db
		sfx_player.play()
