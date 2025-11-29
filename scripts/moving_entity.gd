extends CharacterBody2D

var river_tilemap: TileMapLayer
const RIVER_ATLAS_COORDINATES = Vector2i(7, 8)
const RIVER_FLOW = Vector2(-1, 1)       # flowing down
const RIVER_SPEED = 0.5                 # tweak as needed
const SPEED = 300.0

func apply_river_current(direction, delta) -> Vector2:
	var tile = river_tilemap.local_to_map(river_tilemap.to_local(global_position))
	var id = river_tilemap.get_cell_source_id(tile)
	var tile_pos = river_tilemap.local_to_map(river_tilemap.to_local(global_position))
	var atlas = river_tilemap.get_cell_atlas_coords(tile_pos)

	if atlas == RIVER_ATLAS_COORDINATES:
		direction += RIVER_FLOW * RIVER_SPEED
		print("Direction after river flow: " + str(direction))
	return direction

func _physics_process(delta: float) -> void:

	
	move_and_slide()
