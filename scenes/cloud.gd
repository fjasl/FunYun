extends Area2D
class_name Cloud

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const FALL_SPEED: float = 1.0  # 原始逻辑：每帧 1 像素

var is_hit: bool = false
var is_disappearing: bool = false

signal hit

func _ready():
	if animated_sprite.sprite_frames:
		animated_sprite.play("idle")

func _physics_process(_delta: float):
	# 原始逻辑：每帧下落 1 像素
	position.y += FALL_SPEED
	
	if is_disappearing:
		modulate.a -= 0.02
		if modulate.a <= 0.6:
			queue_free()
		return

	if is_hit:
		animated_sprite.play("hit")
		is_disappearing = true
		hit.emit()
		return

	# 原始消失条件1：y > CLOUD_HIDE_Y 时淡出
	if position.y > GameConfig.CLOUD_HIDE_Y:
		modulate.a -= 0.1
		if modulate.a <= 0:
			queue_free()
		return
	
	# 原始消失条件2：超出屏幕底部
	var screen_bottom := -GameConfig.y_now + GameConfig.stage_height - 50
	if position.y > screen_bottom:
		queue_free()

func on_hit() -> void:
	if is_hit or is_disappearing:
		return
	is_hit = true
