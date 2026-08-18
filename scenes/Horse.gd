extends Area2D
class_name Horse

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const FALL_SPEED: float = 1.0  # 原始逻辑：每帧 1 像素

var x_speed: float = 3.0  # 原始 HORSE_SPEED
var is_hit: bool = false
var is_disappearing: bool = false

signal hit

func _ready():
	# 随机初始方向
	if randf() > 0.5:
		x_speed = -x_speed
	_update_facing()
	animated_sprite.play("idle")

func _update_facing():
	# 素材默认朝左，向右飞行时翻转
	animated_sprite.scale.x = -1.0 if x_speed > 0.0 else 1.0

func _physics_process(_delta: float):
	# 原始逻辑：每帧下落 1 像素，水平移动 3 像素
	position.y += FALL_SPEED
	position.x += x_speed
	
	if is_disappearing:
		# 原始逻辑：加速飞走，淡出
		x_speed *= 1.2
		modulate.a -= 0.02
		if position.x < -30 or position.x > GameConfig.stage_width + 30:
			queue_free()
		return

	# 边界反弹
	if position.x <= GameConfig.x_min:
		position.x = GameConfig.x_min
		x_speed = abs(x_speed)
		_update_facing()
	elif position.x >= GameConfig.x_max:
		position.x = GameConfig.x_max
		x_speed = -abs(x_speed)
		_update_facing()

	if is_hit:
		animated_sprite.play("hit")
		is_disappearing = true
		hit.emit()
		return

	# 原始消失条件：超出屏幕
	var screen_bottom := -GameConfig.y_now + 700
	if position.y > screen_bottom:
		queue_free()

func on_hit() -> void:
	if is_hit or is_disappearing:
		return
	is_hit = true
