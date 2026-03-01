extends Node3D

@onready var player = $Player

var milk_count := 0
var milk_target := 10
var milk_label: Label

func _ready():
	AudioManager.play_music("res://assets/audio/music/bawitdaba.mp3", -5.0)
	GameManager.milk_collected.connect(_on_milk_collected)
	build_spa()
	spawn_milk_cartons()
	create_hud()

func build_spa():
	var wood_mat = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.3, 0.18)

	var wood_dark = StandardMaterial3D.new()
	wood_dark.albedo_color = Color(0.3, 0.2, 0.12)

	var water_mat = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.85, 0.88, 0.92, 0.6)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var milk_water_mat = StandardMaterial3D.new()
	milk_water_mat.albedo_color = Color(0.95, 0.95, 0.93, 0.8)
	milk_water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var floor_mesh = BoxMesh.new()
	floor_mesh.size = Vector3(16, 0.5, 16)
	var floor_node = MeshInstance3D.new()
	floor_node.mesh = floor_mesh
	floor_node.material_override = wood_mat
	floor_node.position = Vector3(0, -0.25, 0)
	add_child(floor_node)

	var floor_body = StaticBody3D.new()
	floor_body.position = Vector3(0, -0.25, 0)
	var floor_col = CollisionShape3D.new()
	var floor_shape = BoxShape3D.new()
	floor_shape.size = Vector3(16, 0.5, 16)
	floor_col.shape = floor_shape
	floor_body.add_child(floor_col)
	add_child(floor_body)

	var pool_mesh = BoxMesh.new()
	pool_mesh.size = Vector3(6, 1.0, 8)
	var pool = MeshInstance3D.new()
	pool.mesh = pool_mesh
	pool.material_override = milk_water_mat
	pool.position = Vector3(3, 0.0, -2)
	add_child(pool)

	var pool_rim_mat = StandardMaterial3D.new()
	pool_rim_mat.albedo_color = Color(0.5, 0.35, 0.2)
	var rim_positions = [
		[Vector3(0, 0.6, -6), Vector3(6.4, 0.3, 0.3)],
		[Vector3(0, 0.6, 2), Vector3(6.4, 0.3, 0.3)],
		[Vector3(-3, 0.6, -2), Vector3(0.3, 0.3, 8.4)],
		[Vector3(6, 0.6, -2), Vector3(0.3, 0.3, 8.4)],
	]
	for rim_data in rim_positions:
		var rm = BoxMesh.new()
		rm.size = rim_data[1]
		var r = MeshInstance3D.new()
		r.mesh = rm
		r.material_override = pool_rim_mat
		r.position = rim_data[0] + Vector3(3, 0, 0)
		add_child(r)

	var wall_configs = [
		[Vector3(-8, 2, 0), Vector3(0.4, 4, 16)],
		[Vector3(8, 2, 0), Vector3(0.4, 4, 16)],
		[Vector3(0, 2, -8), Vector3(16, 4, 0.4)],
		[Vector3(0, 2, 8), Vector3(16, 4, 0.4)],
	]
	for wc in wall_configs:
		var wm = BoxMesh.new()
		wm.size = wc[1]
		var wall = MeshInstance3D.new()
		wall.mesh = wm
		wall.material_override = wood_dark
		wall.position = wc[0]
		add_child(wall)

		var wb = StaticBody3D.new()
		wb.position = wc[0]
		var ws = CollisionShape3D.new()
		var wbox = BoxShape3D.new()
		wbox.size = wc[1]
		ws.shape = wbox
		wb.add_child(ws)
		add_child(wb)

	var friend_model = load("res://assets/models/friend.glb")
	if friend_model:
		var friend = friend_model.instantiate()
		friend.position = Vector3(5, 0, -2)
		friend.rotation.y = -PI / 2
		add_child(friend)

	var bench_mat = StandardMaterial3D.new()
	bench_mat.albedo_color = Color(0.4, 0.28, 0.15)
	for bz in [-5.0, -2.0, 1.0]:
		var bm = BoxMesh.new()
		bm.size = Vector3(2, 0.15, 0.6)
		var bench = MeshInstance3D.new()
		bench.mesh = bm
		bench.material_override = bench_mat
		bench.position = Vector3(-5, 0.5, bz)
		add_child(bench)

func spawn_milk_cartons():
	var carton_mat = StandardMaterial3D.new()
	carton_mat.albedo_color = Color(0.95, 0.95, 0.95)

	var label_mat = StandardMaterial3D.new()
	label_mat.albedo_color = Color(0.2, 0.4, 0.9)

	var positions = [
		Vector3(-4, 0.3, -4), Vector3(-4, 0.3, 0), Vector3(-4, 0.3, 3),
		Vector3(2, 0.3, 4), Vector3(5, 0.3, 4),
		Vector3(-2, 0.3, -6), Vector3(1, 0.3, -6),
		Vector3(6, 0.3, 2), Vector3(-6, 0.3, -2),
		Vector3(0, 0.3, 0),
	]
	for pos in positions:
		var area = Area3D.new()
		area.position = pos
		area.set_meta("is_milk", true)

		var carton_mesh = BoxMesh.new()
		carton_mesh.size = Vector3(0.2, 0.4, 0.2)
		var carton = MeshInstance3D.new()
		carton.mesh = carton_mesh
		carton.material_override = carton_mat
		area.add_child(carton)

		var lbl_mesh = BoxMesh.new()
		lbl_mesh.size = Vector3(0.21, 0.15, 0.21)
		var lbl = MeshInstance3D.new()
		lbl.mesh = lbl_mesh
		lbl.material_override = label_mat
		lbl.position = Vector3(0, 0.05, 0)
		area.add_child(lbl)

		var col = CollisionShape3D.new()
		var shape = SphereShape3D.new()
		shape.radius = 0.8
		col.shape = shape
		area.add_child(col)

		area.body_entered.connect(_on_milk_body_entered.bind(area))
		add_child(area)

func create_hud():
	var canvas = CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	milk_label = Label.new()
	milk_label.text = "MILK: 0 / %d" % milk_target
	milk_label.position = Vector2(20, 20)
	milk_label.add_theme_font_size_override("font_size", 28)
	milk_label.add_theme_color_override("font_color", Color.WHITE)
	canvas.add_child(milk_label)

func _on_milk_body_entered(body, area):
	if body.is_in_group("player"):
		GameManager.drink_milk()
		area.queue_free()

func _on_milk_collected():
	milk_count += 1
	if milk_label:
		milk_label.text = "MILK: %d / %d" % [milk_count, milk_target]
	if milk_count >= milk_target:
		if milk_label:
			milk_label.text = "WHOLE MILK. ALL OF IT."
