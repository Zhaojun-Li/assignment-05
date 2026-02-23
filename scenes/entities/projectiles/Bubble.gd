extends Area2D
class_name Bubble

signal popped(trapped_type: int)

# -1 = left, 1 = right
var dir: int = 1
var float_up: bool = false
var t: float = 0.0
var trapped_enemy: Enemy = null
var _escape_timer: float = 0.0

@export var horizontal_speed: float = 280.0
@export var float_speed: float = 90.0
@export var push_time: float = 0.35
@export var lifetime: float = 2.8
@export var escape_time: float = 3.0

func _ready() -> void:
	add_to_group("bubbles")

	# Detect collision
	body_entered.connect(_on_body_entered)

	# Timer for empty bubble
	$Timer.one_shot = true
	$Timer.wait_time = lifetime
	$Timer.timeout.connect(_on_lifetime_timeout)
	$Timer.start()

func _process(delta: float) -> void:
	t += delta

	# If enemy is trapped, move with bubble
	if trapped_enemy != null and is_instance_valid(trapped_enemy):
		trapped_enemy.global_position = global_position
		
		# pop if player is inside enemy bubble
		for b in get_overlapping_bodies():
			if b is Player:
				pop()
				return
				
		# Count escape time
		_escape_timer += delta
		if _escape_timer >= escape_time:
			_release_enemy_as_aggressive()
			return

	# Move horizontally then up
	if float_up or t >= push_time:
		float_up = true
		global_position.y -= float_speed * delta
	else:
		global_position.x += horizontal_speed * dir * delta

	# Remove bubble if it leave screen
	if global_position.y < -60:
		_cleanup_and_free(false)

func _on_body_entered(body: Node) -> void:
	# Pop trapped enemy
	if body is Player:
		if trapped_enemy != null and is_instance_valid(trapped_enemy):
			pop()
		return

	if trapped_enemy != null:
		return

	# Trap enemy
	if body is Enemy:
		var e: Enemy = body
		e.call_deferred("set_trapped", true)
		trapped_enemy = e
		float_up = true
		_escape_timer = 0.0
		$Timer.stop()

func pop() -> void:
	var trapped_type := 0

	# Destroy trapped enemy
	if trapped_enemy != null and is_instance_valid(trapped_enemy):
		trapped_type = trapped_enemy.get_enemy_type()
		trapped_enemy.queue_free()
		trapped_enemy = null

	emit_signal("popped", trapped_type)
	queue_free()

func _on_lifetime_timeout() -> void:
	_cleanup_and_free(false)

func _cleanup_and_free(_award_points: bool) -> void:
	# Remove if enemy is inside
	if trapped_enemy != null and is_instance_valid(trapped_enemy):
		trapped_enemy.queue_free()
		trapped_enemy = null
	queue_free()

# Enemy escape and turn aggressive
func _release_enemy_as_aggressive() -> void:
	if trapped_enemy == null or not is_instance_valid(trapped_enemy):
		queue_free()
		return

	trapped_enemy.call_deferred("set_trapped", false)
	trapped_enemy.call_deferred("make_aggressive")

	trapped_enemy = null
	queue_free()
