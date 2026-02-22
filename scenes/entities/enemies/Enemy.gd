extends CharacterBody2D
class_name Enemy

enum EnemyType { NORMAL, AGGRESSIVE }
enum State { ACTIVE, TRAPPED }

@export var enemy_type: EnemyType = EnemyType.NORMAL
@export var speed: float = 90.0
var _base_speed: float
@export var aggressive_speed_multiplier: float = 2.0
@export var gravity: float = 1200.0

var dir: int = 1
var state: State = State.ACTIVE

var _saved_layer: int
var _saved_mask: int

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var ledge_ray: RayCast2D = get_node_or_null("LedgeRay")
@onready var hurt_box: Area2D = get_node_or_null("HurtBox")

func _ready() -> void:
	add_to_group("enemies")
	_saved_layer = collision_layer
	_saved_mask = collision_mask
	_base_speed = speed

	# HurtBox 负责伤害玩家（比 physics body 碰撞更稳定）
	if hurt_box:
		hurt_box.body_entered.connect(_on_hurtbox_body_entered)

func get_enemy_type() -> int:
	return int(enemy_type)
	
func make_aggressive() -> void:
	enemy_type = EnemyType.AGGRESSIVE
	speed = _base_speed * aggressive_speed_multiplier
	if sprite:
		sprite.modulate = Color(1.0, 0.0, 0.0, 0.5)

func _on_hurtbox_body_entered(body: Node) -> void:
	if state != State.ACTIVE:
		return
	if body is Player:
		body.hurt()

func set_trapped(trapped: bool) -> void:
	state = State.TRAPPED if trapped else State.ACTIVE

	# 停止 AI/物理更新
	set_physics_process(not trapped)
	set_process(not trapped)

	# 彻底移出碰撞系统（最稳）
	if trapped:
		collision_layer = 0
		collision_mask = 0
	else:
		collision_layer = _saved_layer
		collision_mask = _saved_mask

	# 禁用所有 CollisionShape2D
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = trapped

	# TRAPPED 时关闭 HurtBox（避免还能伤人）
	if hurt_box:
		hurt_box.monitoring = not trapped
		hurt_box.monitorable = not trapped

	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if state != State.ACTIVE:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0

	velocity.x = dir * speed
	move_and_slide()

	# 撞墙反向
	if is_on_wall():
		dir *= -1

	# 可选：边缘探测（防止掉落）
	if ledge_ray:
		ledge_ray.target_position = Vector2(12 * dir, 45)
		ledge_ray.force_raycast_update()
		if is_on_floor() and not ledge_ray.is_colliding():
			dir *= -1
			
	_update_facing()
	
func _update_facing() -> void:
	if sprite:
		# dir = +1 面向右（不翻），dir = -1 面向左（翻转）
		sprite.flip_h = (dir > 0)
