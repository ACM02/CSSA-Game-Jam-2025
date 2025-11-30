class_name Boudler

extends "physics_entity.gd"

@onready var player = get_tree().get_first_node_in_group("player")

func try_push(vector):
	var collision = move_and_collide(vector)
	
	return collision == null

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	var physics_effects = get_physics_effects()
	var collision = move_and_collide(physics_effects * delta, true)

	if !collision or collision.get_collider() != player:
		#print("Boulder is NOT touching player!")
		move_and_collide(physics_effects * delta)
	#else:
		#print("Boulder is touching player!")
