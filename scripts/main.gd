extends Node2D

signal game_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Play intro sequence
	$HUD.play_narrative_sequence("One must imagine Sisyphus happy.")

	# Wait for the HUD to signal that the text is finished
	await $HUD.transition_finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_death() -> void:
#	Move player to start
# 	Reset health
#	Reset enemies?
	print("Game over!")
	game_over.emit()
