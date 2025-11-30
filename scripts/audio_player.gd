extends Node2D

@onready var player_a: AudioStreamPlayer = $PlayerA
@onready var player_b: AudioStreamPlayer = $PlayerB

var current_player: AudioStreamPlayer
var next_player: AudioStreamPlayer

var fading := false

func _ready():
	current_player = player_a
	next_player = player_b

func play_music(stream: AudioStream, fade_time := 1.5):
	if fading:
		return

	fading = true
	
	# Prepare next player
	next_player.stream = stream
	next_player.volume_db = -80
	next_player.play()
	
	# Linear volumes
	var current_vol := 1.0
	var next_vol := 0.0
	
	var tween = create_tween()
	tween.tween_method(
		func(v):
			next_vol = v
			next_player.volume_db = linear_to_db(next_vol)
			current_vol = 1.0 - v
			current_player.volume_db = linear_to_db(current_vol)
			, 0.0, 1.0, fade_time
	)
	
	await tween.finished
	current_player.stop()

	# Swap players
	var temp = current_player
	current_player = next_player
	next_player = temp

	fading = false
