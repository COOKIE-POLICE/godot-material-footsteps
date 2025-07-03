extends CharacterBody3D
class_name Player

const SPEED: float = 5.0
@export var JUMP_VELOCITY: float = 10.0

@onready var head: Node3D = $Head
var sensitivity: float = 0.008

func _ready() -> void:
	toggle_pause()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump_input()
	move()
	move_and_slide()
	handle_pause_inputs()

func move() -> void:
	var input_dir: Vector2 = Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

func handle_jump_input() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * sensitivity
		head.rotation.x = clamp(head.rotation.x - event.relative.y * sensitivity, deg_to_rad(-70), deg_to_rad(80))

func toggle_pause() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func handle_pause_inputs() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()
