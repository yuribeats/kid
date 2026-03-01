extends CharacterBody3D

@export var speed := 8.0
@export var sprint_speed := 14.0
@export var jump_force := 10.0
@export var gravity := 25.0
@export var dash_speed := 25.0
@export var dash_duration := 0.2
@export var dash_cooldown := 0.5
@export var mouse_sensitivity := 0.002

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var model = $Model

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := Vector3.ZERO
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_on_floor := false
var invincible := false
var invincible_timer := 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.0, 0.8)
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	handle_timers(delta)
	handle_gravity(delta)
	handle_jump()
	handle_dash(delta)
	handle_movement(delta)
	handle_invincibility(delta)
	move_and_slide()
	was_on_floor = is_on_floor()

func handle_timers(delta):
	if is_on_floor():
		coyote_timer = 0.15
	else:
		coyote_timer -= delta
	jump_buffer_timer -= delta
	dash_cooldown_timer -= delta

func handle_gravity(delta):
	if not is_on_floor() and not is_dashing:
		velocity.y -= gravity * delta

func handle_jump():
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = 0.1
	if jump_buffer_timer > 0 and coyote_timer > 0 and not is_dashing:
		velocity.y = jump_force
		coyote_timer = 0
		jump_buffer_timer = 0
	if Input.is_action_just_released("jump") and velocity.y > 0:
		velocity.y *= 0.5

func handle_dash(delta):
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		invincible = true
		invincible_timer = dash_duration
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		dash_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if dash_direction == Vector3.ZERO:
			dash_direction = -transform.basis.z

	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed
		velocity.y = 0
		if dash_timer <= 0:
			is_dashing = false

func handle_movement(delta):
	if is_dashing:
		return
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed = speed
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * 2)
		velocity.z = move_toward(velocity.z, 0, current_speed * 2)

func handle_invincibility(delta):
	if invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			invincible = false

func get_caught():
	if invincible:
		return
	GameManager.catch_player()
	invincible = true
	invincible_timer = 1.5
	velocity = -transform.basis.z * 10
	velocity.y = 5
