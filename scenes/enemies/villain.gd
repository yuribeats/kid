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

func _ready():
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

func chase_state(delta):
	if not player:
		return
	var dir = (player.global_position - global_position)
	dir.y = 0
	var dist = dir.length()

	if dist < catch_range:
		if not player.invincible:
			player.get_caught()
			state = State.STUNNED
			stun_timer = stun_duration
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

func get_dodged():
	GameManager.dodge_villain()
	state = State.STUNNED
	stun_timer = stun_duration
