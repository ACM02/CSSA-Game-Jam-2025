extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_health_change(new_health: Variant) -> void:
	$HealthBar.value = new_health
	


func _on_main_game_over() -> void:
	$GameText.visible = true
	print("Show game over text")
