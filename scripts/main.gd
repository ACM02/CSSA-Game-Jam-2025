extends Node2D

signal game_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.spawn($StartPoint.position)
	# Play intro sequence
	$HUD.play_narrative_sequence(["One must imagine Sisyphus happy."])
	# Wait for the HUD to signal that the text is finished
	await $HUD.transition_finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_death() -> void:
#	Move player to start
# 	Reset health
#	Reset enemies?
	var respawn_logic = func():
		$Player.health = 100
		$Player.emit_signal("health_change", 100)
		$Player.evolve()

		$Player.stamina = $Player.max_stamina
		$Player.emit_signal("stamina_change", $Player.max_stamina, false)

	$HUD.play_narrative_sequence(["I drowned in my sorrows.\nMy lungs suffocate the way they always have."
	, "But I must push the boulder to the top."], 3.0, respawn_logic)
	await $HUD.transition_finished

	print("Game over!")
	game_over.emit()


func _on_player_mud_death() -> void:
	_on_player_death()

func _on_boulder_mud_death() -> void:
	_on_player_death()
