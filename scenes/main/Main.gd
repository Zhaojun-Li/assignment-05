extends Node
class_name Main

enum State { MENU, PLAY, GAME_OVER }
var state: State = State.MENU

var level_scene := preload("res://scenes/world/Level01.tscn")

@onready var menu_screen: Control = $Menu
@onready var game_over_screen: Control = $GameOver
@onready var level_holder: Node = $LevelHolder

func _ready() -> void:
	_show_menu()

func _process(_delta: float) -> void:
	# Minimal state machine per PDF (Menu / GameOver prompt + restart)
	# You can use "start" or "fire" for Menu, and "restart" or "fire" for GameOver.
	if state == State.MENU:
		if Input.is_action_just_pressed("start") or Input.is_action_just_pressed("fire"):
			_start_game()

	elif state == State.GAME_OVER:
		if Input.is_action_just_pressed("restart") or Input.is_action_just_pressed("fire"):
			_show_menu()

func _start_game() -> void:
	state = State.PLAY
	menu_screen.visible = false
	game_over_screen.visible = false

	_clear_level_holder()

	var level = level_scene.instantiate()
	level_holder.add_child(level)

	# 让 Level 可以回调 Main（当玩家没命时）
	if level.has_signal("request_game_over"):
		level.request_game_over.connect(_on_level_request_game_over)

func _on_level_request_game_over(final_score: int) -> void:
	# 进入 GameOver
	state = State.GAME_OVER
	_clear_level_holder()

	game_over_screen.visible = true
	menu_screen.visible = false

	# 如果你在 GameOver.tscn 里用了 InfoLabel，就显示分数
	if game_over_screen.has_node("InfoLabel"):
		game_over_screen.get_node("InfoLabel").text = "Game Over\nScore: %d\nPress R (or Fire) to Restart" % final_score

func _show_menu() -> void:
	state = State.MENU
	_clear_level_holder()

	menu_screen.visible = true
	game_over_screen.visible = false

func _clear_level_holder() -> void:
	for c in level_holder.get_children():
		c.queue_free()
