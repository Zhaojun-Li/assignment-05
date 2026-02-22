extends CharacterBody2D
class_name Player

signal bubble_spawned(bubble: Bubble)
signal died()

@export var speed: float = 220.0
@export var jump_velocity: float = -550.0
@export var gravity: float = 1200.0

@export var bubble_scene: PackedScene

# HUD values
@export var max_health: int = 3
@export var start_lives: int = 3

# 你要的“闪烁 + 无敌 + 禁止射击”时长
@export var invuln_duration: float = 1.0
@export var flicker_interval: float = 0.08

var facing: int = 1
var health: int
var lives: int

# timers
var invuln_timer: float = 0.0         # >0 表示无敌/闪烁
var shoot_lock_timer: float = 0.0     # >0 表示不能射击
var _flicker_timer: float = 0.0

@onready var sprite_node: CanvasItem = _find_sprite_node()

func _ready() -> void:
	lives = start_lives
	health = max_health

	# 开局（按开始后会重新生成 Player 或 reset）
	# 如果你的流程是“开始游戏时新建 Level01”，那么这里就是开局点：
	_start_invuln_and_lock()

func _physics_process(delta: float) -> void:
	# ---- timers update ----
	if invuln_timer > 0.0:
		invuln_timer -= delta
		_flicker_timer += delta

		if _flicker_timer >= flicker_interval:
			_flicker_timer = 0.0
			_set_sprite_visible(not _get_sprite_visible())

		if invuln_timer <= 0.0:
			invuln_timer = 0.0
			_set_sprite_visible(true)

	if shoot_lock_timer > 0.0:
		shoot_lock_timer -= delta
		if shoot_lock_timer < 0.0:
			shoot_lock_timer = 0.0

	# ---- gravity ----
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0

	# ---- horizontal ----
	var axis := Input.get_axis("move_left", "move_right")
	if axis != 0.0:
		facing = signi(axis)
	velocity.x = axis * speed

	# ---- jump ----
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		var level := get_parent()
		if level and level.has_method("play_sfx_jump"):
			level.play_sfx_jump()

	# ---- fire bubble (locked during invuln/start) ----
	if Input.is_action_just_pressed("fire") and shoot_lock_timer <= 0.0:
		_shoot_bubble()
		var level := get_parent()
		if level and level.has_method("play_sfx_fire"):
			level.play_sfx_fire()

	move_and_slide()

func hurt() -> void:
	# 无敌期间不受伤（你说“闪烁一秒进入无敌”）
	if invuln_timer > 0.0:
		return

	# 受伤：血-1
	health -= 1

	# 受伤后：无敌+闪烁 1 秒，并锁定射击 1 秒（移动不受影响）
	_start_invuln_and_lock()

	# 血到 0：命-1，回满血
	if health <= 0:
		lives -= 1

		if lives <= 0:
			emit_signal("died")
			return

		health = max_health

func _start_invuln_and_lock() -> void:
	invuln_timer = invuln_duration
	shoot_lock_timer = invuln_duration
	_flicker_timer = 0.0
	_set_sprite_visible(true) # 从可见开始闪烁

func _shoot_bubble() -> void:
	if bubble_scene == null:
		return

	# Optional limit: max 5 bubbles
	if get_tree().get_nodes_in_group("bubbles").size() >= 5:
		return

	var b: Bubble = bubble_scene.instantiate()
	get_parent().add_child(b)

	b.global_position = global_position + Vector2(30 * facing, -10)
	b.dir = facing

	emit_signal("bubble_spawned", b)

# ---------- helpers ----------
func _find_sprite_node() -> CanvasItem:
	# 兼容 Sprite2D 或 AnimatedSprite2D
	if has_node("Sprite2D"):
		return $Sprite2D as CanvasItem
	if has_node("AnimatedSprite2D"):
		return $AnimatedSprite2D as CanvasItem
	return null

func _set_sprite_visible(v: bool) -> void:
	if sprite_node:
		sprite_node.visible = v

func _get_sprite_visible() -> bool:
	if sprite_node:
		return sprite_node.visible
	return true
