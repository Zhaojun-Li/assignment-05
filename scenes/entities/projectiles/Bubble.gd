extends Area2D
class_name Bubble

signal popped(trapped_type: int)

var dir: int = 1

@export var horizontal_speed: float = 280.0
@export var float_speed: float = 90.0

@export var push_time: float = 0.35
var float_up: bool = false
var t: float = 0.0

@export var lifetime: float = 2.8

var trapped_enemy: Enemy = null

@export var escape_time: float = 3.0
var _escape_timer: float = 0.0

func _ready() -> void:
	add_to_group("bubbles")

	# 监听与 PhysicsBody 的碰撞（Enemy/Player 都是 CharacterBody2D）
	body_entered.connect(_on_body_entered)

	$Timer.one_shot = true
	$Timer.wait_time = lifetime
	$Timer.timeout.connect(_on_lifetime_timeout)
	$Timer.start()

func _process(delta: float) -> void:
	t += delta

	# 抓到敌人后，让敌人跟着泡泡移动
	if trapped_enemy != null and is_instance_valid(trapped_enemy):
		trapped_enemy.global_position = global_position
	# 3 秒未戳爆 -> 敌人逃脱变强
		_escape_timer += delta
		if _escape_timer >= escape_time:
			_release_enemy_as_aggressive()
			return
			
	# 水平 -> 上浮
	if float_up or t >= push_time:
		float_up = true
		global_position.y -= float_speed * delta
	else:
		global_position.x += horizontal_speed * dir * delta

	# 顶部出界就删（空泡泡/有敌人都行）
	if global_position.y < -60:
		_cleanup_and_free(false) # false=不计分，不 pop

func _on_body_entered(body: Node) -> void:
	# 玩家触碰 trapped bubble -> pop
	if body is Player:
		if trapped_enemy != null and is_instance_valid(trapped_enemy):
			pop()
		return

	# 已经抓到一个就不再抓
	if trapped_enemy != null:
		return

	# trap enemy
	if body is Enemy:
		var e: Enemy = body
		e.set_trapped(true)
		trapped_enemy = e
		float_up = true
		_escape_timer = 0.0
		# trapped bubble 不再自动消失（避免“不给分就删敌人”）
		$Timer.stop()

func pop() -> void:
	var trapped_type := 0

	if trapped_enemy != null and is_instance_valid(trapped_enemy):
		trapped_type = trapped_enemy.get_enemy_type()
		trapped_enemy.queue_free()
		trapped_enemy = null

	emit_signal("popped", trapped_type)
	queue_free()

func _on_lifetime_timeout() -> void:
	# 空泡泡到期直接消失（不计分）
	_cleanup_and_free(false)

func _cleanup_and_free(_award_points: bool) -> void:
	# 这里不主动删除 trapped enemy（因为 trapped bubble timer 已 stop）
	queue_free()

func _release_enemy_as_aggressive() -> void:
	if trapped_enemy == null or not is_instance_valid(trapped_enemy):
		queue_free()
		return

	# 让敌人逃脱：恢复 ACTIVE + 变强 + 继续掉落/巡逻
	trapped_enemy.set_trapped(false)
	trapped_enemy.make_aggressive()

	# 给它一个“蹦出泡泡”的小推力（可选）
	trapped_enemy.velocity = Vector2(120 * dir, -220)

	trapped_enemy = null
	queue_free()
