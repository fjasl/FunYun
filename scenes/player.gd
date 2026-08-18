extends CharacterBody2D
class_name Player

signal game_over

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var foot_area: Area2D = $FootArea

const JUMP_POWER: float = -22.0
const GRAVITY: float = 1.0
const BOUNCE_POWER: float = -18.0
const GROUND_Y: float = 566.4

var is_jumping: bool = false
var y_speed: float = 0.0
var current_action: String = "stand"
var facing_right: bool = true

func _ready():
	position.y = GROUND_Y
	foot_area.area_entered.connect(_on_foot_area_entered)

func _physics_process(_delta: float):
	# 水平：平滑跟随鼠标（原始逻辑：差距/8）
	var mouse_x := get_global_mouse_position().x
	var target_x := clampf(mouse_x, GameConfig.x_min, GameConfig.x_max)
	position.x += (target_x - position.x) / 8.0
	facing_right = mouse_x >= position.x

	if is_jumping:
		# 原始逻辑：每帧加 GRAVITY，每帧移动 y_speed
		y_speed += GRAVITY
		var new_y := position.y + y_speed
		
		# 落地检测
		if new_y >= GROUND_Y:
			position.y = GROUND_Y
			y_speed = 0.0
			is_jumping = false
			current_action = "stand"
			if GameConfig.total_score > 0:
				game_over.emit()
		else:
			position.y = new_y
			current_action = "jump"
	else:
		if abs(target_x - position.x) > 5.0:
			current_action = "run"
		else:
			current_action = "stand"

	if animated_sprite:
		animated_sprite.play(current_action)
		animated_sprite.scale.x = 1.0 if facing_right else -1.0

func _on_foot_area_entered(area: Area2D):
	if area is Cloud or area is Horse:
		if area.is_hit or area.is_disappearing:
			return
		area.on_hit()
		if is_jumping:
			y_speed = BOUNCE_POWER

func start_jump() -> void:
	if not is_jumping:
		is_jumping = true
		y_speed = JUMP_POWER
		current_action = "jump"

func reset() -> void:
	is_jumping = false
	y_speed = 0.0
	position.y = GROUND_Y
	current_action = "stand"
	if animated_sprite:
		animated_sprite.play("stand")
