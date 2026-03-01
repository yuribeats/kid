extends Node

signal villain_dodged
signal villains_cleared
signal player_caught
signal milk_collected
signal game_phase_changed(phase)

enum Phase { STREET, SPA }

var current_phase: Phase = Phase.STREET
var villains_dodged: int = 0
var villains_to_dodge: int = 15
var milk_drunk: int = 0
var is_paused: bool = false

func _ready():
	pass

func dodge_villain():
	villains_dodged += 1
	villain_dodged.emit()
	if villains_dodged >= villains_to_dodge:
		villains_cleared.emit()
		transition_to_spa()

func transition_to_spa():
	current_phase = Phase.SPA
	game_phase_changed.emit(Phase.SPA)
	SceneManager.change_scene("res://scenes/levels/spa.tscn")

func catch_player():
	player_caught.emit()

func drink_milk():
	milk_drunk += 1
	milk_collected.emit()

func reset():
	villains_dodged = 0
	milk_drunk = 0
	current_phase = Phase.STREET

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
