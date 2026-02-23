extends CharacterBody2D
class_name Player

signal bubble_spawned(bubble: Bubble)
signal died()

# -1 = left, 1 = right
var facing: int = 1
var health: int
var lives: int
var invuln_timer: float = 0.0
var shoot_lock_timer: float = 0.0
var _flicker_timer: float = 0.0

# Find sprite node for flickering
@onready var sprite_node: CanvasItem = _find_sprite_node()

@export var speed: float = 220.0
@export var jump_velocity: float = -550.0
@export var gravity: float = 1200.0
@export var bubble_scene: PackedScene
@export var max_health: int = 3
@export var start_lives: int = 3
@export var invuln_duration: float = 1.0
@export var flicker_interval: float = 0.08

func _ready() -> void:
	lives = start_lives
	health = max_health
	# Invulnerability at start
	_start_invuln_and_lock()

func _physics_process(delta: float) -> void:
	# Invulnerability timer
	if invuln_timer > 0.0:
		invuln_timer -= delta
		_flicker_timer += delta

		# Create flicker effect by toggle sprite
		if _flicker_timer >= flicker_interval:
			_flicker_timer = 0.0
			_set_sprite_visible(not _get_sprite_visible())
			
		if invuln_timer <= 0.0:
			invuln_timer = 0.0
			_set_sprite_visible(true)

	# Shooting timer
	if shoot_lock_timer > 0.0:
		shoot_lock_timer -= delta
		if shoot_lock_timer < 0.0:
			shoot_lock_timer = 0.0

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0

	# Horizontal movement
	var axis := Input.get_axis("move_left", "move_right")
	# Update facing
	if axis != 0.0:
		facing = signi(axis)

	velocity.x = axis * speed

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		# Play jump sound
		var level := get_parent()
		if level and level.has_method("play_sfx_jump"):
			level.play_sfx_jump()

	# Shoot
	if Input.is_action_just_pressed("fire") and shoot_lock_timer <= 0.0:
		_shoot_bubble()
		# Play fire sound
		var level := get_parent()
		if level and level.has_method("play_sfx_fire"):
			level.play_sfx_fire()

	move_and_slide()

# Player take damage
func hurt() -> void:
	if invuln_timer > 0.0:
		return

	# Reduce health
	health -= 1
	# Play ouch sound
	var level := get_parent()
	if level and level.has_method("play_sfx_ouch"):
		level.play_sfx_ouch()
	
	# Knockup
	velocity.y = jump_velocity * 0.5
	
	_start_invuln_and_lock()

	if health <= 0:
		lives -= 1
		if lives <= 0:
			emit_signal("died")
			return
		# Reset health if player still has lives
		health = max_health

# Start invulnerability and shooting lock
func _start_invuln_and_lock() -> void:
	invuln_timer = invuln_duration
	shoot_lock_timer = invuln_duration
	_flicker_timer = 0.0
	_set_sprite_visible(true)

# Create and spawn bubble
func _shoot_bubble() -> void:
	if bubble_scene == null:
		return

	# Max number of bubble
	if get_tree().get_nodes_in_group("bubbles").size() >= 5:
		return

	# Create bubble
	var b: Bubble = bubble_scene.instantiate()
	get_parent().add_child(b)

	# Spawn bubble
	b.global_position = global_position + Vector2(30 * facing, -10)
	b.dir = facing
	emit_signal("bubble_spawned", b)

# Find sprite node for flickering
func _find_sprite_node() -> CanvasItem:
	if has_node("Sprite2D"):
		return $Sprite2D as CanvasItem
	if has_node("AnimatedSprite2D"):
		return $AnimatedSprite2D as CanvasItem
	return null

# Set sprite visibility
func _set_sprite_visible(v: bool) -> void:
	if sprite_node:
		sprite_node.visible = v

# Get sprite visibility state
func _get_sprite_visible() -> bool:
	if sprite_node:
		return sprite_node.visible
	return true
