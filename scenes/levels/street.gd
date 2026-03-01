extends Node3D

@onready var player = $Player
@onready var hud = $HUD

var villain_fat_scene = preload("res://scenes/enemies/villain_fat.tscn")
var villain_tall_scene = preload("res://scenes/enemies/villain_tall.tscn")

var spawn_timer := 0.0
var spawn_interval := 2.5
var spawned_count := 0
var max_villains := 25

func _ready():
	AudioManager.play_music("res://assets/audio/music/bawitdaba.mp3", -3.0)
	GameManager.villain_dodged.connect(_on_villain_dodged)
	GameManager.player_caught.connect(_on_player_caught)
	GameManager.villains_cleared.connect(_on_villains_cleared)
	build_city()
	spawn_initial_villains()

func build_city():
	var road_mat = StandardMaterial3D.new()
	road_mat.albedo_color = Color(0.15, 0.15, 0.17)
	var sidewalk_mat = StandardMaterial3D.new()
	sidewalk_mat.albedo_color = Color(0.45, 0.44, 0.42)
	var building_colors = [
		Color(0.35, 0.25, 0.22), Color(0.5, 0.45, 0.4),
		Color(0.3, 0.3, 0.35), Color(0.55, 0.5, 0.45),
		Color(0.4, 0.35, 0.3), Color(0.28, 0.28, 0.3),
		Color(0.6, 0.55, 0.48), Color(0.38, 0.32, 0.28),
	]

	var road_mesh = BoxMesh.new()
	road_mesh.size = Vector3(200, 0.05, 12)
	var road = MeshInstance3D.new()
	road.mesh = road_mesh
	road.material_override = road_mat
	road.position = Vector3(0, 0.01, 0)
	add_child(road)

	for side in [-1, 1]:
		var sw_mesh = BoxMesh.new()
		sw_mesh.size = Vector3(200, 0.15, 4)
		var sw = MeshInstance3D.new()
		sw.mesh = sw_mesh
		sw.material_override = sidewalk_mat
		sw.position = Vector3(0, 0.05, side * 8)
		add_child(sw)

	for side in [-1, 1]:
		var x_offset = -80.0
		while x_offset < 80.0:
			var w = randf_range(6, 14)
			var h = randf_range(8, 30)
			var d = randf_range(8, 16)
			var gap = randf_range(1, 3)

			var bmat = StandardMaterial3D.new()
			bmat.albedo_color = building_colors[randi() % building_colors.size()]

			var bmesh = BoxMesh.new()
			bmesh.size = Vector3(w, h, d)
			var b = MeshInstance3D.new()
			b.mesh = bmesh
			b.material_override = bmat
			b.position = Vector3(x_offset + w / 2.0, h / 2.0, side * (10 + d / 2.0 + 2))
			add_child(b)

			var bcol = StaticBody3D.new()
			bcol.position = b.position
			var bshape = CollisionShape3D.new()
			var box = BoxShape3D.new()
			box.size = Vector3(w, h, d)
			bshape.shape = box
			bcol.add_child(bshape)
			add_child(bcol)

			for floor_i in range(int(h / 3.0)):
				for win_x in range(int(w / 2.5)):
					var win_mat = StandardMaterial3D.new()
					var lit = randf() > 0.4
					if lit:
						win_mat.albedo_color = Color(0.9, 0.85, 0.5)
						win_mat.emission_enabled = true
						win_mat.emission = Color(0.9, 0.85, 0.5)
						win_mat.emission_energy_multiplier = 0.3
					else:
						win_mat.albedo_color = Color(0.1, 0.12, 0.18)
					var wm = BoxMesh.new()
					wm.size = Vector3(1.2, 1.5, 0.05)
					var win = MeshInstance3D.new()
					win.mesh = wm
					win.material_override = win_mat
					var wx = x_offset + 1.5 + win_x * 2.5
					var wy = 2.0 + floor_i * 3.0
					var wz = side * (10 + 2 - 0.01) if side > 0 else side * (10 + 2 - 0.01)
					win.position = Vector3(wx, wy, wz)
					add_child(win)

			x_offset += w + gap

	for i in range(30):
		var lx = -70 + i * 5.0
		for side in [-1, 1]:
			var pole_mat = StandardMaterial3D.new()
			pole_mat.albedo_color = Color(0.25, 0.25, 0.25)
			var pole_mesh = CylinderMesh.new()
			pole_mesh.top_radius = 0.06
			pole_mesh.bottom_radius = 0.08
			pole_mesh.height = 5.0
			var pole = MeshInstance3D.new()
			pole.mesh = pole_mesh
			pole.material_override = pole_mat
			pole.position = Vector3(lx, 2.5, side * 6.5)
			add_child(pole)

			var light_mat = StandardMaterial3D.new()
			light_mat.albedo_color = Color(1, 0.95, 0.8)
			light_mat.emission_enabled = true
			light_mat.emission = Color(1, 0.95, 0.8)
			light_mat.emission_energy_multiplier = 2.0
			var bulb_mesh = SphereMesh.new()
			bulb_mesh.radius = 0.15
			bulb_mesh.height = 0.3
			var bulb = MeshInstance3D.new()
			bulb.mesh = bulb_mesh
			bulb.material_override = light_mat
			bulb.position = Vector3(lx, 5.2, side * 6.5)
			add_child(bulb)

			if i % 3 == 0:
				var ol = OmniLight3D.new()
				ol.position = Vector3(lx, 5.0, side * 6.5)
				ol.light_energy = 0.6
				ol.omni_range = 12.0
				ol.light_color = Color(1, 0.95, 0.8)
				ol.shadow_enabled = false
				add_child(ol)

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
	add_child(villain)
	villain.global_position = pos
	spawned_count += 1

func get_random_spawn_position() -> Vector3:
	var angle = randf() * TAU
	var dist = 15.0 + randf() * 10.0
	var px = player.global_position.x + cos(angle) * dist
	var pz = clampf(player.global_position.z + sin(angle) * dist, -5.0, 5.0)
	return Vector3(px, 0, pz)

func _on_villain_dodged():
	if hud:
		hud.update_dodge_count(GameManager.villains_dodged, GameManager.villains_to_dodge)

func _on_player_caught():
	if hud:
		hud.flash_caught()

func _on_villains_cleared():
	pass
