class_name physics_entity
extends CharacterBody2D

signal mud_death
signal void_death

var ground_tilemap: TileMapLayer

const GROUND_ATLAS = Vector2i(0, 0)
const WATER_SE_ATLAS = Vector2i(1, 0)
const RAMP_ATLAS = Vector2i(2, 0)
const MUD_ATLAS = Vector2i(3, 0)
const BORDER_ATLAS = Vector2i(4, 0)
const WATER_NW_ATLAS = Vector2i(6, 0)

const RAMP_SPEED = 100
var RAMP_DIRECTION = Vector2(-1, 1).normalized()

var FLOW_SE = Vector2(1, 0.5).normalized()
var FLOW_NW = Vector2(-1, -0.5).normalized()
const RIVER_SPEED = 40                 # tweak as needed

var mud_time_limit = 3.0

var AFFECTED_BY_WATER = true
var AFFECTED_BY_RAMP = true
var AFFECTED_BY_MUD = true
var AFFECTED_BY_MUD_STUCK = false
var AFFECTED_BY_MUD_SLOW = false

var mudCounter = 0
var default_sprite_pos = Vector2.ZERO

# Defines the sinking effect for any entity
const SINK_SHADER_CODE = """
shader_type canvas_item;
uniform float sink_y = 1000.0; // Cutoff line in local sprite coordinates

varying float local_y;

void vertex() {
	local_y = VERTEX.y;
}

void fragment() {
	if (local_y > sink_y) {
		discard;
	}
}
"""

func _ready() -> void:
	ground_tilemap = get_tree().get_first_node_in_group("ground")
	
	# Apply shader to the sprite if it exists
	if has_node("Sprite2D"):
		default_sprite_pos = $Sprite2D.position
		var mat = ShaderMaterial.new()
		var shader = Shader.new()
		shader.code = SINK_SHADER_CODE
		mat.shader = shader
		$Sprite2D.material = mat

# Returns a multiplier for movement speed (0.0 to 1.0) based on terrain and traits
func get_speed_multiplier() -> float:
	var atlas = currTile()
	if atlas == MUD_ATLAS:
		if AFFECTED_BY_MUD_STUCK:
			return 0.05 # Essentially stuck, but barely twitching to show effort
		if AFFECTED_BY_MUD_SLOW:
			return 0.5 # Slowed movement
	return 1.0

func get_physics_effects() -> Vector2:
	var atlas = currTile()

	var effect_direction = Vector2.ZERO

	if atlas == RAMP_ATLAS && AFFECTED_BY_RAMP:
		effect_direction = RAMP_DIRECTION * RAMP_SPEED
	elif AFFECTED_BY_WATER:
		if atlas == WATER_SE_ATLAS:
			effect_direction = FLOW_SE * RIVER_SPEED
		elif atlas == WATER_NW_ATLAS:
			effect_direction = FLOW_NW * RIVER_SPEED

	return effect_direction

func currTile() -> Vector2i:
	var tile = ground_tilemap.local_to_map(ground_tilemap.to_local(global_position))
	var id = ground_tilemap.get_cell_source_id(tile)
	var tile_pos = ground_tilemap.local_to_map(ground_tilemap.to_local(global_position))
	var atlas = ground_tilemap.get_cell_atlas_coords(tile_pos)
	return atlas

func isInMud():
	return currTile() == MUD_ATLAS
	
func isInWater():
	var t = currTile()
	return t == WATER_SE_ATLAS or t == WATER_NW_ATLAS

func _physics_process(delta: float) -> void:
	# --- VOID DEATH LOGIC ---
	# Check if the tile under us actually exists. 
	# get_cell_source_id returns -1 if the cell is empty (void).
	var tile_pos = ground_tilemap.local_to_map(ground_tilemap.to_local(global_position))
	var source_id = ground_tilemap.get_cell_source_id(tile_pos)
	
	if source_id == -1:
		# We are off the map
		emit_signal("void_death")
		# Optional: Add a falling animation/tween here before resetting
		return

	if isInMud():
		mudCounter += delta

		# --- VISUAL SINKING LOGIC ---
		if has_node("Sprite2D"):
			var percent_sunk = clamp(mudCounter / mud_time_limit, 0.0, 1.0)
			var max_sink_pixels = 15.0 # How deep they go visually
			
			# 1. Move sprite down physically
			$Sprite2D.position.y = default_sprite_pos.y + (max_sink_pixels * percent_sunk)
			
			# 2. Update shader to clip the bottom
			# Calculate bottom of sprite (approx texture height / 2 if centered)
			var tex_h = $Sprite2D.texture.get_height() if $Sprite2D.texture else 32.0
			var bottom_y = tex_h / 2.0
			
			# Raise the clip line as we sink
			var current_sink_y = bottom_y - (max_sink_pixels * percent_sunk)
			$Sprite2D.material.set_shader_parameter("sink_y", current_sink_y)

		if mudCounter >= mud_time_limit:
			mud_death.emit()
			mudCounter = 0
	else:
		if mudCounter > 0:
			mudCounter = 0
			if has_node("Sprite2D"):
				$Sprite2D.position = default_sprite_pos
				# Move shader cutoff far below sprite to show everything
				$Sprite2D.material.set_shader_parameter("sink_y", 1000.0)
