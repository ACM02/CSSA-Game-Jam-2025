class_name Boudler

extends "physics_entity.gd"

@onready var player = get_tree().get_first_node_in_group("player")

const speed = 80
var touching_player := false

func try_push(vector):
	move_and_collide(vector)

func _physics_process(delta: float) -> void:
	var physics_effects = get_physics_effects()
	move_and_collide(physics_effects * delta)
	#velocity = physics_effects

	# ----------------------------------------------------------
	# 1. Check predictive collision ONCE
	# ----------------------------------------------------------
	#var predicted = move_and_collide(velocity * delta, true)
#
	#if predicted:
		#var collider = predicted.get_collider()
#
		#if collider.is_in_group("player"):
			#touching_player = true
		#else:
			#touching_player = false
	#else:
		#touching_player = false

	# ----------------------------------------------------------
	# 2. Apply movement logic based on touching status
	# ----------------------------------------------------------
	#if touching_player:
		## Smooth movement: follow player's input direction continuously
		#var pv = Vector2(
			#Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			#Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		#)
#
		#if pv.length() > 0.1:
			#velocity = pv.normalized() * speed
		#else:
			#velocity = Vector2.ZERO

	# ----------------------------------------------------------
	# 3. Move once
	# ----------------------------------------------------------
	#move_and_collide(velocity * delta)
