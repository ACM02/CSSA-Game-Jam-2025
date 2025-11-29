extends CanvasLayer

signal transition_finished

@onready var narrative_layer = $NarrativeLayer
@onready var black_screen = $NarrativeLayer/BlackScreen
@onready var narrative_label = $NarrativeLayer/NarrativeText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# On game start, begin with the screen for introduction
	narrative_label.modulate.a = 0.0
	black_screen.modulate.a = 1.0
	narrative_layer.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_narrative_sequence(text_content: String, duration: float = 3.0):
	narrative_layer.visible = true
	narrative_label.text = text_content
	
	var tween = create_tween()
	
	# 1. Fade in black
	tween.tween_property(black_screen, "modulate:a", 1.0, 0.5)
	
	# 2. Fade in text
	tween.tween_property(narrative_label, "modulate:a", 1.0, 1.0)
	
	# 3. Wait for reading time
	tween.tween_interval(duration)
	
	# 4. Fade out text
	tween.tween_property(narrative_label, "modulate:a", 0.0, 1.0)
	
	# 5. Fade out black
	tween.tween_property(black_screen, "modulate:a", 0.0, 2.0)
	
	# 6. Callback when done
	tween.tween_callback(_on_sequence_complete)
	
	
func _on_sequence_complete() -> void:
	narrative_layer.visible = false
	emit_signal("transition_finished")


func _on_player_health_change(new_health: Variant) -> void:
	$HealthBar.value = new_health
	

func _on_main_game_over() -> void:
	$GameText.visible = true
	print("Show game over text")
