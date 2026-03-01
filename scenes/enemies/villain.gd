extends CharacterBody3D

enum State { IDLE, CHASE, STUNNED }

@export var chase_speed := 4.5
@export var detection_range := 20.0
@export var catch_range := 1.2
@export var stun_duration := 2.0
@export var is_fat := true

var state: State = State.IDLE
var player: CharacterBody3D = null
var stun_timer := 0.0
var gravity := 20.0
var chase_timer := 0.0
var max_chase_time := 10.0

func _ready():
	build_body()
	if is_fat:
		chase_speed = 3.5
	else:
		chase_speed = 5.5
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	match state:
		State.IDLE:
			idle_state()
		State.CHASE:
			chase_state(delta)
		State.STUNNED:
			stunned_state(delta)
	move_and_slide()

func idle_state():
	if player and global_position.distance_to(player.global_position) < detection_range:
		state = State.CHASE
		chase_timer = 0.0

func chase_state(delta):
	if not player:
		return
	var dir = (player.global_position - global_position)
	dir.y = 0
	var dist = dir.length()
	chase_timer += delta
	if chase_timer >= max_chase_time:
		get_dodged()
		return
	if dist < catch_range:
		if not player.invincible:
			player.get_caught()
			state = State.STUNNED
			stun_timer = stun_duration
		else:
			get_dodged()
		return
	dir = dir.normalized()
	velocity.x = dir.x * chase_speed
	velocity.z = dir.z * chase_speed
	look_at(player.global_position * Vector3(1, 0, 1) + global_position * Vector3(0, 1, 0), Vector3.UP)

func stunned_state(delta):
	velocity.x = 0
	velocity.z = 0
	stun_timer -= delta
	if stun_timer <= 0:
		state = State.CHASE
		chase_timer = 0.0

func get_dodged():
	GameManager.dodge_villain()
	queue_free()

func build_body():
	var skin = StandardMaterial3D.new()
	skin.albedo_color = Color(0.72, 0.55, 0.42)
	var shirt = StandardMaterial3D.new()
	shirt.albedo_color = Color(0.03, 0.03, 0.03)
	var pants = StandardMaterial3D.new()
	pants.albedo_color = Color(0.05, 0.04, 0.04)
	var boots_m = StandardMaterial3D.new()
	boots_m.albedo_color = Color(0.08, 0.06, 0.04)
	if is_fat:
		_build_fat(skin, shirt, pants, boots_m)
	else:
		_build_tall(skin, shirt, pants, boots_m)

func _cap(pos: Vector3, r: float, h: float, mat: Material):
	var m = CapsuleMesh.new()
	m.radius = r
	m.height = h
	var n = MeshInstance3D.new()
	n.mesh = m
	n.material_override = mat
	n.position = pos
	add_child(n)

func _sph(pos: Vector3, r: float, mat: Material):
	var m = SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	var n = MeshInstance3D.new()
	n.mesh = m
	n.material_override = mat
	n.position = pos
	add_child(n)

func _bx(pos: Vector3, sz: Vector3, mat: Material):
	var m = BoxMesh.new()
	m.size = sz
	var n = MeshInstance3D.new()
	n.mesh = m
	n.material_override = mat
	n.position = pos
	add_child(n)

func _face_spr(pos: Vector3, tex_path: String, px: float):
	var spr = Sprite3D.new()
	var tex = load(tex_path)
	if tex:
		spr.texture = tex
	spr.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	spr.position = pos
	spr.pixel_size = px
	spr.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	spr.alpha_scissor_threshold = 0.5
	add_child(spr)

func _build_fat(skin, shirt, pants, boots):
	_sph(Vector3(0, 1.52, 0), 0.15, skin)
	_cap(Vector3(0, 1.15, 0), 0.25, 0.70, shirt)
	_cap(Vector3(-0.30, 1.20, 0), 0.08, 0.55, shirt)
	_cap(Vector3(0.30, 1.20, 0), 0.08, 0.55, shirt)
	_sph(Vector3(-0.30, 0.90, 0), 0.05, skin)
	_sph(Vector3(0.30, 0.90, 0), 0.05, skin)
	_cap(Vector3(-0.12, 0.48, 0), 0.10, 0.78, pants)
	_cap(Vector3(0.12, 0.48, 0), 0.10, 0.78, pants)
	_bx(Vector3(-0.12, 0.06, 0.02), Vector3(0.14, 0.14, 0.20), boots)
	_bx(Vector3(0.12, 0.06, 0.02), Vector3(0.14, 0.14, 0.20), boots)
	_face_spr(Vector3(0, 1.52, 0), "res://assets/textures/face_fat.png", 0.004)

func _build_tall(skin, shirt, pants, boots):
	_sph(Vector3(0, 1.85, 0), 0.13, skin)
	_cap(Vector3(0, 1.40, 0), 0.16, 0.85, shirt)
	_cap(Vector3(-0.22, 1.38, 0), 0.055, 0.70, shirt)
	_cap(Vector3(0.22, 1.38, 0), 0.055, 0.70, shirt)
	_sph(Vector3(-0.22, 1.00, 0), 0.04, skin)
	_sph(Vector3(0.22, 1.00, 0), 0.04, skin)
	_cap(Vector3(-0.10, 0.58, 0), 0.08, 0.90, pants)
	_cap(Vector3(0.10, 0.58, 0), 0.08, 0.90, pants)
	_bx(Vector3(-0.10, 0.06, 0.02), Vector3(0.12, 0.14, 0.18), boots)
	_bx(Vector3(0.10, 0.06, 0.02), Vector3(0.12, 0.14, 0.18), boots)
	_face_spr(Vector3(0, 1.85, 0), "res://assets/textures/face_tall.png", 0.004)
