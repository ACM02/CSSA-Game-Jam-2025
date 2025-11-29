class_name physics_entity
extends CharacterBody2D

# Needs to interact with:
# Water
# Mud
# Ramp

var ground_tilemap: TileMapLayer

const GROUND_ATLAS = Vector2i(0, 0)
const WATER_ATLAS = Vector2i(1, 0)
const RAMP_ATLAS = Vector2i(2, 0)
const MUD_ATLAS = Vector2i(3, 0)
const BORDER_ATLAS = Vector2i(4, 0)

const RAMP_SPEED = 50
var RAMP_DIRECTION = Vector2(-1, 1).normalized()

var RIVER_FLOW = Vector2(-1, 1).normalized()       # flowing down
const RIVER_SPEED = 30                 # tweak as needed

func _ready() -> void:
	ground_tilemap = get_tree().get_first_node_in_group("ground")

func get_physics_effects() -> Vector2:
	var tile = ground_tilemap.local_to_map(ground_tilemap.to_local(global_position))
	var id = ground_tilemap.get_cell_source_id(tile)
	var tile_pos = ground_tilemap.local_to_map(ground_tilemap.to_local(global_position))
	var atlas = ground_tilemap.get_cell_atlas_coords(tile_pos)

	var effect_direction = Vector2.ZERO

	if atlas == GROUND_ATLAS:
		pass
	elif atlas == WATER_ATLAS:
		effect_direction = RIVER_FLOW * RIVER_SPEED
	elif atlas == RAMP_ATLAS:
		effect_direction = RAMP_DIRECTION * RAMP_SPEED
	elif atlas == MUD_ATLAS:
		pass
	elif atlas == BORDER_ATLAS:
		pass
	return effect_direction

#func _physics_process(delta: float) -> void:
	#move_and_slide()
