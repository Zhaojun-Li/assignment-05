extends CharacterBody2D
class_name Enemy

# Enemy type
enum EnemyType { NORMAL, AGGRESSIVE }
# Enemy state
enum State { ACTIVE, TRAPPED }

var dir: int = 1
var state: State = State.ACTIVE

var _base_speed: float
var _saved_layer: int
var _saved_mask: int

@export var enemy_type: EnemyType = EnemyType.NORMAL
@export var speed: float = 90.0
@export var aggressive_speed_multiplier: float = 2.0
@export var gravity: float = 1200.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var ledge_ray: RayCast2D = get_node_or_null("LedgeRay")
@onready var hurt_box: Area2D = get_node_or_null("HurtBox")

func _ready() -> void:
	add_to_group("enemies")

	_saved_layer = collision_layer
	_saved_mask = collision_mask
	_base_speed = speed

	if hurt_box:
		hurt_box.body_entered.connect(_on_hurtbox_body_entered)

# Return enemy type for score
func get_enemy_type() -> int:
	return int(enemy_type)

# Make enemy faster and red
func make_aggressive() -> void:
	enemy_type = EnemyType.AGGRESSIVE
	speed = _base_speed * aggressive_speed_multiplier

	if sprite:
		sprite.modulate = Color(1.0, 0.0, 0.0, 0.5)

# Damage player when touched
func _on_hurtbox_body_entered(body: Node) -> void:
	if state != State.ACTIVE:
		return
	if body is Player:
		body.hurt()

# Open/close trap state
func set_trapped(trapped: bool) -> void:
	state = State.TRAPPED if trapped else State.ACTIVE

	set_physics_process(not trapped)
	set_process(not trapped)

	if trapped:
		collision_layer = 0
		collision_mask = 0
	else:
		collision_layer = _saved_layer
		collision_mask = _saved_mask

	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = trapped

	if hurt_box:
		hurt_box.monitoring = not trapped
		hurt_box.monitorable = not trapped

	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if state != State.ACTIVE:
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0

	# Move left or right
	velocity.x = dir * speed
	move_and_slide()

	# Turn around when hitting wall
	if is_on_wall():
		dir *= -1

	# Turn around at platform edge
	if ledge_ray:
		ledge_ray.target_position = Vector2(12 * dir, 45)
		ledge_ray.force_raycast_update()
		if is_on_floor() and not ledge_ray.is_colliding():
			dir *= -1

	_update_facing()

# Flip sprite on direction
func _update_facing() -> void:
	if sprite:
		sprite.flip_h = (dir > 0)
