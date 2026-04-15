extends CharacterBody3D

const BASE_SPEED = 6.0
const SPRINT_MULTIPLIER = 1.8
const SLIDE_SPEED = 14.0
const SLIDE_DURATION = 0.5
const SLIDE_COOLDOWN = 3.0
const JUMP_VELOCITY = 5.0
const GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

var rotation_x: float = 0.0
var mouse_sensitivity := Vector2(0.15, 0.15)
var sliding: bool = false
var slide_timer: float = 0.0
var slide_cooldown_timer: float = 0.0
var slide_direction: Vector3 = Vector3.ZERO

onready var camera: Camera3D = $Camera3D

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        rotate_y(deg2rad(-event.relative.x * mouse_sensitivity.x))
        rotation_x = clamp(rotation_x - event.relative.y * mouse_sensitivity.y, -90.0, 90.0)
        camera.rotation_degrees.x = rotation_x

func _physics_process(delta: float) -> void:
    if slide_cooldown_timer > 0.0:
        slide_cooldown_timer = max(slide_cooldown_timer - delta, 0.0)

    var direction = Vector3.ZERO
    if Input.is_action_pressed("move_forward"):
        direction -= transform.basis.z
    if Input.is_action_pressed("move_backward"):
        direction += transform.basis.z
    if Input.is_action_pressed("move_left"):
        direction -= transform.basis.x
    if Input.is_action_pressed("move_right"):
        direction += transform.basis.x

    direction = direction.normalized()

    if sliding:
        slide_timer -= delta
        velocity.x = slide_direction.x * SLIDE_SPEED
        velocity.z = slide_direction.z * SLIDE_SPEED
        if slide_timer <= 0.0:
            sliding = false
            slide_cooldown_timer = SLIDE_COOLDOWN
    else:
        var speed = BASE_SPEED
        if Input.is_action_pressed("sprint") and direction != Vector3.ZERO:
            speed *= SPRINT_MULTIPLIER
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed

        if is_on_floor():
            if Input.is_action_just_pressed("slide") and direction != Vector3.ZERO and slide_cooldown_timer <= 0.0:
                sliding = true
                slide_timer = SLIDE_DURATION
                slide_direction = direction
            elif Input.is_action_just_pressed("jump"):
                velocity.y = JUMP_VELOCITY

    if not is_on_floor():
        velocity.y -= GRAVITY * delta

    move_and_slide()
