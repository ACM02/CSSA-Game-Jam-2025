extends Node2D

signal game_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_death() -> void:
#	Move player to start
# 	Reset health
#	Reset enemies?
	print("Game over!")
	game_over.emit()
