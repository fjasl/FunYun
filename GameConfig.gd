extends Node

# 游戏版本
const GAME_VERSION := "1.0"

# 屏幕尺寸
var stage_width := 940.0
var stage_height := 590.0

# 云朵参数
const CLOUD_SPEED := 1.0
const CLOUD_HIDE_Y := 400.0  # 原始值
const CLOUD_X_SPACING := 150.0
const CLOUD_Y_SPACING := 110.0
const CLOUD_BASE_SCORE := 10.0
const CLOUD_ADD_SCORE := 1.0

# 物理参数
const JUMP_POWER := -22.0
const BOUNCE_POWER := -18.0
const GRAVITY := 1.0
const PLAYER_SPEED := 10.0

# 边界
const X_PADDING := 40.0
const Y_PADDING := 40.0

# 马参数
const HORSE_SPEED := 3.0
const HORSE_SPACING := 2000.0
const HORSE_NEXT := 1000.0

# 卷云参数
const CIRRUS_X_SPEED := 1.0
const CIRRUS_Y_SPACING := 240.0

# 动态变量
var skala := 1.0
var maxskala := 1.0
var minskala := 0.5
var y_now := 0.0
var hit_time := 0.0
var total_score := 0.0

# 边界
var x_min := X_PADDING
var x_max := stage_width - X_PADDING
var y_min := Y_PADDING
var y_max := stage_height - Y_PADDING

func _ready():
	x_min = X_PADDING
	x_max = stage_width - X_PADDING
	y_min = Y_PADDING
	y_max = stage_height - Y_PADDING
