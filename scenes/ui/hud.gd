extends CanvasLayer

@onready var dodge_label = $DodgeLabel
@onready var caught_flash = $CaughtFlash

func _ready():
	caught_flash.modulate.a = 0

func update_dodge_count(current: int, total: int):
	dodge_label.text = "DODGED: %d / %d" % [current, total]

func flash_caught():
	caught_flash.modulate.a = 0.6
	var tween = create_tween()
	tween.tween_property(caught_flash, "modulate:a", 0.0, 0.5)
