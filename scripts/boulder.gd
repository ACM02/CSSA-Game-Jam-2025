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
