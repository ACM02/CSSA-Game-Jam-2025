extends TileMapLayer

const boundary_atlas_coord = Vector2i(9,7)
const main_source = 0
const layers = {
	ground = 0,
	walls = 1
}

func place_boundaries():
	var offsets = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(1, 0),
		Vector2i(-1, 0),
	]
	var used = get_used_cells()
	for spot in used:
		for offset in offsets:
			var current_cell = spot + offset 
			if get_cell_source_id(current_cell) == -1:
				set_cell(current_cell, main_source, boundary_atlas_coord)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	place_boundaries()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
