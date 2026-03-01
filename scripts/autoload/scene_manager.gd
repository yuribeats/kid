extends Node

var transition_overlay: ColorRect

func _ready():
	transition_overlay = ColorRect.new()
	transition_overlay.color = Color(0, 0, 0, 0)
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	canvas.add_child(transition_overlay)
	add_child(canvas)

func change_scene(path: String):
	var tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 1.0, 0.4)
	await tween.finished
	get_tree().change_scene_to_file(path)
	var tween2 = create_tween()
	tween2.tween_property(transition_overlay, "color:a", 0.0, 0.4)
