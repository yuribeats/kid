extends Node3D

@onready var player = $Player
@onready var hud = $HUD

var villain_fat_scene = preload("res://scenes/enemies/villain_fat.tscn")
var villain_tall_scene = preload("res://scenes/enemies/villain_tall.tscn")

var spawn_timer := 0.0
var spawn_interval := 3.0
var spawned_count := 0
var max_villains := 20

func _ready():
	AudioManager.play_music("res://assets/audio/music/bawitdaba.mp3", -3.0)
	GameManager.villain_dodged.connect(_on_villain_dodged)
	GameManager.player_caught.connect(_on_player_caught)
	spawn_initial_villains()

func spawn_initial_villains():
	for i in range(5):
		spawn_villain(get_random_spawn_position())

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval and spawned_count < max_villains:
		spawn_timer = 0
		spawn_villain(get_random_spawn_position())

func spawn_villain(pos: Vector3):
	var scene = villain_fat_scene if randi() % 2 == 0 else villain_tall_scene
	var villain = scene.instantiate()
	villain.global_position = pos
	add_child(villain)
	spawned_count += 1

func get_random_spawn_position() -> Vector3:
	var angle = randf() * TAU
	var dist = 15.0 + randf() * 10.0
	var px = player.global_position.x + cos(angle) * dist
	var pz = player.global_position.z + sin(angle) * dist
	return Vector3(px, 0, pz)

func _on_villain_dodged():
	if hud:
		hud.update_dodge_count(GameManager.villains_dodged, GameManager.villains_to_dodge)

func _on_player_caught():
	if hud:
		hud.flash_caught()
