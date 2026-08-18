extends AudioStreamPlayer

func _ready():
	finished.connect(_on_finished)
	play()

func _on_finished():
	play()

func toggle_bgm() -> void:
	if playing:
		stop()
	else:
		play()

func set_bgm_volume(value_db: float) -> void:
	volume_db = value_db
