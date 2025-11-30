extends Node2D

signal game_over

@onready var player = $Player
@onready var hud = $HUD
@onready var start_point = $StartPoint

var track_number = 0
var current_player_spawn: Vector2
var current_boulder_spawn: Vector2

const tracks = [
	preload("res://music/stage 1.wav"),
	preload("res://music/stage 2.wav"),
	preload("res://music/stage 3.wav")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_player_spawn = start_point.position
	# Default boulder location (from your original code)
	current_boulder_spawn = Vector2(267, 33)

	AudioPlayer.play_music(tracks[track_number], 2.0)
	
	player.spawn(current_player_spawn)
	
	# Connect signals
	player.mud_death.connect(func(): _on_player_death_with_reason(player.DEATH_TYPE.MUD))
	$Boulder.mud_death.connect(func(): _on_player_death_with_reason(player.DEATH_TYPE.MUD))
	
	player.void_death.connect(func(): _on_player_death_with_reason(player.DEATH_TYPE.EXHAUSTION))
	$Boulder.void_death.connect(func(): _on_player_death_with_reason(player.DEATH_TYPE.EXHAUSTION))

	# Play intro sequence
	$HUD.play_narrative_sequence(["One must imagine Sisyphus happy."])
	# Wait for the HUD to signal that the text is finished
	await $HUD.transition_finished
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_death_with_reason(reason: int) -> void:
	var current_phase = player.phase
	var narrative_lines = []
	var should_evolve = false
	
	# Narrative Branching based on Script
	match current_phase:
		player.PHASES.blob:
			if reason == player.DEATH_TYPE.DROWNING:
				narrative_lines = [
					"I drowned in my sorrows.",
					"My lungs suffocate the way they always have.",
					"But I must push the boulder to the top."
				]
				should_evolve = true
				track_number = 1
				
				current_player_spawn = Vector2(623, -122)
				current_boulder_spawn = Vector2(644, -137)
			else:
				narrative_lines = [
					"I was too weak.",
					"But I must push the boulder to the top."
				]

		player.PHASES.fish:
			if reason == player.DEATH_TYPE.MUD:
				narrative_lines = [
					"I foundered into the mire.",
					"My legs crumble under the weight of it all.",
					"But I must push the boulder to the top."
				]
				should_evolve = true
				track_number = 2
				
			else:
				narrative_lines = [
					"I was too weak.",
					"But I must push the boulder to the top."
				]

		player.PHASES.lizard:
			if reason == player.DEATH_TYPE.ENEMY:
				narrative_lines = [
					"I was visited by the Grim Reaper.",
					"They took from me an unbeating heart.",
					"But I must push the boulder to the top."
				]
				should_evolve = true
				track_number = 2 # TODO: Make 4th track and put it here
				
			elif reason == player.DEATH_TYPE.MUD:
				narrative_lines = [
					"I was too slow.",
					"But I must push the boulder to the top."
				]
			else:
				narrative_lines = [
					"I was too weak.",
					"But I must push the boulder to the top."
				]

		player.PHASES.primate:
			if reason == player.DEATH_TYPE.EXHAUSTION:
				narrative_lines = [
					"I must push the boulder to the top.",
					"There, I hope to find a cliff, where I can push the boulder off and destroy it once and for all.",
					"But there is no cliff ahead. It keeps going.",
					"I don't have the strength to push anymore."
				]
				# End game logic triggers here
			else:
				narrative_lines = [
					"I was too weak.",
					"But I must push the boulder to the top."
				]

	# Fallback
	if narrative_lines.is_empty():
		narrative_lines = ["One must imagine Sisyphus happy."]

	if should_evolve:
		print("Switching to track " + str(track_number))
		AudioPlayer.play_music(tracks[track_number], 7.0)
		

	var respawn_logic = func():
		player.spawn(current_player_spawn)
		$Boulder.position = current_boulder_spawn 
		$Boulder.mudCounter = 0
		
		if should_evolve:
			player.evolve()
			# Apply global changes for boulder based on new phase
			if player.phase >= player.PHASES.lizard:
				$Boulder.mud_time_limit = 10.0
			else:
				$Boulder.mud_time_limit = 5.0

	hud.play_narrative_sequence(narrative_lines, narrative_lines.size(), respawn_logic)
	await hud.transition_finished

	# Check for endgame state
	if current_phase == player.PHASES.primate and reason == player.DEATH_TYPE.EXHAUSTION:
		print("End Game Sequence / Choices would appear here")
