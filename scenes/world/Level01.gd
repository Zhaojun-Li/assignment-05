extends Node2D
class_name Level01

signal request_game_over(final_score: int)

var score: int = 0

@onready var music: AudioStreamPlayer2D = $Music
@onready var sfx_fire: AudioStreamPlayer2D = $SFXFire
@onready var sfx_jump: AudioStreamPlayer2D = $SFXJump
@onready var sfx_pop: AudioStreamPlayer2D = $SFXPop

@onready var player: Player = $Player
@onready var hud := $HUD

# 在 Inspector 里绑定 Enemy.tscn
@export var enemy_scene: PackedScene

# 你可以在 Inspector 改这些点（确保 3–6 个）
@export var enemy_spawn_points: Array[Vector2] = [
	Vector2(200, 200),
	Vector2(300, 150),
	Vector2(600, 0),
	Vector2(800, 150),
	Vector2(900, 200),
]

func _ready() -> void:
	_update_hud()

	# 连接：泡泡生成 -> 让 Level 监听 popped 来加分
	player.bubble_spawned.connect(_on_player_bubble_spawned)
	# 连接：玩家命=0 -> 请求 GameOver
	player.died.connect(_on_player_died)

	_spawn_enemies()
	
		# 背景音乐（开始游戏就播）
	if music and not music.playing:
		music.play()

func play_sfx_fire() -> void:
	if sfx_fire:
		sfx_fire.play()

func play_sfx_jump() -> void:
	if sfx_jump:
		sfx_jump.play()

func play_sfx_pop() -> void:
	if sfx_pop:
		sfx_pop.play()

func _process(_delta: float) -> void:
	_update_hud()

func _spawn_enemies() -> void:
	if enemy_scene == null:
		return
	for p in enemy_spawn_points:
		var e: Enemy = enemy_scene.instantiate()
		e.global_position = p
		add_child(e)

func _update_hud() -> void:
	hud.get_node("ScoreLabel").text = "Score: %d" % score
	hud.get_node("LivesLabel").text = "Lives: %d" % player.lives
	hud.get_node("HealthLabel").text = "Health: %d" % player.health

func _on_player_bubble_spawned(b: Bubble) -> void:
	if b and is_instance_valid(b):
		b.popped.connect(_on_bubble_popped)

func _on_bubble_popped(trapped_type: int) -> void:
	play_sfx_pop()
	# 计分：普通 100，强敌 300
	if trapped_type == int(Enemy.EnemyType.AGGRESSIVE):
		score += 300
	else:
		score += 100

func _on_player_died() -> void:
	emit_signal("request_game_over", score)
