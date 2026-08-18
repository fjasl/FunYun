extends Node2D

const CLOUD_SCENE := preload("res://scenes/Cloud.tscn")
const HORSE_SCENE := preload("res://scenes/Horse.tscn")

@onready var game_world: Node2D = $GameWorld
@onready var flying_layer: Node2D = $GameWorld/FlyingLayer
@onready var player: Player = $GameWorld/Player
@onready var camera: Camera2D = $GameCamera
@onready var background: Sprite2D = $Background
@onready var score_label: Label = $UI/ScoreLabel
@onready var combo_label: Label = $UI/ComboLabel

var last_platform: Node2D = null
var horse_next: float = 0.0
var cloud_x_spacing: float = 150.0

var is_game_running: bool = false
var is_game_over: bool = false

const STAGE_W: float = 940.0
const STAGE_H: float = 590.0
const GROUND_Y: float = 566.4

func _ready():
	player.game_over.connect(_on_player_game_over)
	_start_new_game()

func _start_new_game():
	is_game_running = true
	is_game_over = false

	player.position = Vector2(STAGE_W / 2.0, 566.4)
	player.reset()

	# 初始化相机位置：让角色在屏幕底部可见
	camera.position = Vector2(STAGE_W / 2.0, GROUND_Y - STAGE_H * 0.4)
	background.position = camera.position
	# 设置相机边界
	camera.limit_top = -100000
	camera.limit_bottom = 100000

	horse_next = GameConfig.HORSE_NEXT
	cloud_x_spacing = GameConfig.CLOUD_X_SPACING

	_clear_flying_objects()
	_reset_game_data()

	# 初始平台
	var start_x := randf_range(GameConfig.X_PADDING + 20.0, STAGE_W - GameConfig.X_PADDING - 20.0)
	_make_cloud(start_x, 200.0)
	
	for i in range(4):
		var new_x := _get_close_pos(last_platform.position.x, cloud_x_spacing)
		var new_y := last_platform.position.y - GameConfig.CLOUD_Y_SPACING
		_make_cloud(new_x, new_y)

	set_process(true)

func _reset_game_data():
	GameConfig.total_score = 0.0
	GameConfig.hit_time = 0
	GameConfig.skala = 1.0
	GameConfig.y_now = 0.0

func _on_player_game_over():
	if not is_game_running or is_game_over:
		return
	is_game_running = false
	is_game_over = true
	set_process(false)
	await get_tree().create_timer(1.5).timeout
	_start_new_game()

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_game_running:
			player.start_jump()

func _process(_delta: float):
	if not is_game_running:
		return

	# 原始逻辑：先更新 y_now，再更新相机
	GameConfig.y_now = maxf(0.0, -player.position.y + STAGE_H * 0.6)
	_update_camera()

	score_label.text = "分数：%d" % int(GameConfig.total_score)
	combo_label.text = "连击：%d" % GameConfig.hit_time

	_spawn_clouds()

func _spawn_clouds():
	if last_platform == null:
		return

	# 原始逻辑：player.y - lastCloud.y < stageHeight 时生成新平台
	if player.position.y - last_platform.position.y < STAGE_H:
		if GameConfig.y_now > horse_next:
			horse_next += GameConfig.HORSE_SPACING
			_make_horse(300.0, last_platform.position.y - GameConfig.CLOUD_Y_SPACING)
		elif cloud_x_spacing < 400.0:
			var new_x := _get_close_pos(last_platform.position.x, cloud_x_spacing)
			_make_cloud(new_x, last_platform.position.y - GameConfig.CLOUD_Y_SPACING)
			cloud_x_spacing += 5.0
		else:
			var new_x := randf_range(GameConfig.X_PADDING + 20.0, STAGE_W - GameConfig.X_PADDING - 20.0)
			_make_cloud(new_x, last_platform.position.y - GameConfig.CLOUD_Y_SPACING)

func _update_camera():
	# 原始逻辑：根据 y_speed 调整相机跟随速度
	# 基准位置为静止时的相机位置，y_now 增加时相机上移
	var target_y := (GROUND_Y - STAGE_H * 0.4) - GameConfig.y_now
	var div := 10.0
	
	if player.y_speed > 20.0:
		if player.y_speed > 60.0:
			div = 1.98
		elif player.y_speed > 40.0:
			div = 2.0
		else:
			div = 2.02
	
	camera.position.y += (target_y - camera.position.y) / div
	# 背景跟随相机，始终铺满屏幕
	background.position = camera.position

func _make_cloud(x: float, y: float):
	var cloud := CLOUD_SCENE.instantiate() as Cloud
	cloud.position = Vector2(x, y)
	cloud.scale = Vector2(GameConfig.skala, GameConfig.skala)
	cloud.hit.connect(_on_cloud_hit)
	flying_layer.add_child(cloud)
	last_platform = cloud
	GameConfig.skala = maxf(GameConfig.minskala, GameConfig.skala - 0.002)

func _make_horse(x: float, y: float):
	var horse := HORSE_SCENE.instantiate() as Horse
	horse.position = Vector2(x, y)
	horse.scale = Vector2(GameConfig.skala, GameConfig.skala)
	horse.hit.connect(_on_horse_hit)
	flying_layer.add_child(horse)
	last_platform = horse
	GameConfig.skala = maxf(GameConfig.minskala, GameConfig.skala - 0.002)

func _get_close_pos(x: float, space: float) -> float:
	var sp := randf_range(GameConfig.X_PADDING, minf(space, 300.0))
	var pos_x: float
	if randf() > 0.5:
		pos_x = x + sp
		if pos_x > GameConfig.x_max:
			pos_x = x - sp
	else:
		pos_x = x - sp
		if pos_x < GameConfig.x_min:
			pos_x = x + sp
	return clampf(pos_x, GameConfig.x_min, GameConfig.x_max)

func _clear_flying_objects():
	for child in flying_layer.get_children():
		child.queue_free()
	last_platform = null

func _on_cloud_hit():
	if not is_game_running:
		return
	# 原始逻辑：分数 = 基础分 + 连击数 * 加成
	var score := GameConfig.CLOUD_BASE_SCORE + GameConfig.hit_time * GameConfig.CLOUD_ADD_SCORE
	GameConfig.total_score += score
	GameConfig.hit_time += 1

func _on_horse_hit():
	if not is_game_running:
		return
	# 原始逻辑：马的分数 = 云朵分数 * 10
	var score := (GameConfig.CLOUD_BASE_SCORE + GameConfig.hit_time * GameConfig.CLOUD_ADD_SCORE) * 10.0
	GameConfig.total_score += score
	GameConfig.hit_time += 1
