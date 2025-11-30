extends Sprite2D

@export var duration := 3  # seconds the effect stays

func _ready():
	await get_tree().create_timer(duration).timeout
	queue_free()
