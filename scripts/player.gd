extends "physics_entity.gd"

@export var BLOB_DEAD: Texture2D
@export var BLOB_LEFT: Texture2D
@export var BLOB_RIGHT: Texture2D
@export var BLOB_LEFT_BACK: Texture2D
@export var BLOB_RIGHT_BACK: Texture2D

@export var FISH_DEAD: Texture2D
@export var FISH_LEFT: Texture2D
@export var FISH_RIGHT: Texture2D
@export var FISH_LEFT_BACK: Texture2D
@export var FISH_RIGHT_BACK: Texture2D

@export var LIZARD_DEAD: Texture2D
@export var LIZARD_LEFT: Texture2D
@export var LIZARD_RIGHT: Texture2D
@export var LIZARD_LEFT_BACK: Texture2D
@export var LIZARD_RIGHT_BACK: Texture2D

@export var PRIMATE_DEAD: Texture2D
@export var PRIMATE_LEFT: Texture2D
@export var PRIMATE_RIGHT: Texture2D
@export var PRIMATE_LEFT_BACK: Texture2D
@export var PRIMATE_RIGHT_BACK: Texture2D

@onready var LEFT = BLOB_LEFT
@onready var RIGHT = BLOB_RIGHT
@onready var LEFT_BACK = BLOB_LEFT_BACK
@onready var RIGHT_BACK = BLOB_RIGHT_BACK
@onready var DEAD = BLOB_DEAD

var speed = 50
var isFrontFacing = true
var isRightFacing = false

# Stamina System
var max_stamina: float = 100.0
var stamina: float = 100.0
var stamina_drain_rate = 30.0
var stamina_regen_rate = 15.0
var is_pushing: bool = false

var drowning = false
var can_drown_in_water = true

var sink_position: Vector2 = Vector2.ZERO
var sink_accum: float = 0.0

signal stamina_change(new_stamina, is_colliding)
signal death(reason)

enum PHASES {
	blob = 0,
	fish = 1,
	lizard = 2,
	primate = 3
}

enum DEATH_TYPE {
	GENERIC,
	DROWNING, # Water drowning
	MUD,      # Mud sinking
	ENEMY,
	EXHAUSTION
}

@onready var phase = PHASES.blob

func _ready() -> void:
	super._ready()
	stamina_change.emit(100, false)
	AFFECTED_BY_RAMP=false
	apply_phase_traits()

func die():
	death.emit(DEATH_TYPE.ENEMY)
	$Sprite2D.texture = DEAD

func _physics_process(delta):
	super._physics_process(delta)
	var motion = Vector2.ZERO

	# Water Drowning Logic
	if can_drown_in_water and not drowning and isInWater():
		drowning = true
		$DrowningTimer.start()
		
		# Get the grid coordinate of the water tile we just touched
		var map_pos = ground_tilemap.local_to_map(ground_tilemap.to_local(global_position))
		var tile_center_local = ground_tilemap.map_to_local(map_pos)
		
		# Lock the target position in Global space
		sink_position = ground_tilemap.to_global(tile_center_local)
		sink_accum = 0.0

	elif not isInWater() and not drowning: 
		drowning = false
		$DrowningTimer.stop()
	
	if not drowning:
		var input_vec = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized()
		
		update_sprite_direction(input_vec)
		
		# Apply Mud/Terrain Speed Multiplier
		var current_speed = speed * get_speed_multiplier()
		motion = input_vec * current_speed * delta
		
		# ONLY apply river/slope physics if we are NOT drowning
		motion += (get_physics_effects() * delta)
	else:
		var sink_speed = 5.0 # How fast pixels disappear

		# Slowly move the sprite down relative to the collision shape
		$Sprite2D.position.y += sink_speed * delta
		sink_accum += sink_speed * delta
		
		# The bottom of a centered sprite is at height/2.
		# As we move down by sink_accum, the water line moves UP the sprite by sink_accum.
		var sprite_height = $Sprite2D.get_rect().size.y
		var water_line_y = (sprite_height / 2.0) - sink_accum
		
		# 4. Apply to shader
		$Sprite2D.material.set_shader_parameter("sink_y", water_line_y)

		# PHYSICS: Suction towards center
		var direction_to_center = (sink_position - global_position).normalized()
		var dist = global_position.distance_to(sink_position)
		
		# Move MANUALLY (ignore collisions/walls while dying)
		if dist > 2.0:
			global_position += direction_to_center * 20 * delta
	
	# Reset pushing state for this frame; it will be set true in try_move if we push
	is_pushing = false
	
	#print("Final player direction: " + str(motion))
	# Try move using test_move, not move_and_collide
	if not drowning and motion != Vector2.ZERO:
		try_move(motion, delta)
		
	# Stamina regeneration
	# Recovers when not pushing a boulder
	if is_pushing:
		# Stamina draining is handled in try_move upon successful push
		pass
	else:
		# Check if touching boulder to prevent "cheese" (waiting against the rock)
		if is_touching_boulder():
			stamina_change.emit(stamina, true)
		elif stamina < max_stamina:
			stamina += stamina_regen_rate * delta
			if stamina > max_stamina:
				stamina = max_stamina
			stamina_change.emit(stamina, false)
		else:
			# Ensure green
			stamina_change.emit(stamina, false)

func update_sprite_direction(input_vec: Vector2) -> void:
	if input_vec == Vector2.ZERO:
		return  # No movement, keep current texture

	if input_vec.y != 0:
		if input_vec.y < 0:
			isFrontFacing = false
		else:
			isFrontFacing = true

	if input_vec.x != 0:
		if input_vec.x > 0:
			isRightFacing = true
		elif input_vec.x < 0:
			isRightFacing = false
		
	if isRightFacing && isFrontFacing:
		$Sprite2D.texture = RIGHT
	elif isRightFacing && !isFrontFacing:
		$Sprite2D.texture = RIGHT_BACK
	elif !isRightFacing && isFrontFacing:
		$Sprite2D.texture = LEFT
	elif !isRightFacing && !isFrontFacing:
		$Sprite2D.texture = LEFT_BACK


	# Decide primary movement direction
	#if abs(input_vec.x) > abs(input_vec.y):
		## Horizontal
		#if input_vec.x > 0:
			#$Sprite2D.texture = RIGHT
		#else:
			#$Sprite2D.texture = LEFT
	#else:
		## Vertical
		#if input_vec.y > 0:
			#$Sprite2D.texture = RIGHT_BACK
		#else:
			#$Sprite2D.texture = LEFT_BACK


func try_move(motion: Vector2, delta: float):
	#print("Trying to move: " + str(motion))
	var collision = move_and_collide(motion)

	if collision:
		var collider = collision.get_collider()

		if collider is Boudler:
			if collider.try_push(motion):
				is_pushing = true
				translate(motion)
				
				# Drain stamina
				stamina -= stamina_drain_rate * delta
				stamina_change.emit(stamina, true)
				
				# If no stamina, death
				if stamina <= 0:
					print("Player fainted from exhaustion")
					death.emit(DEATH_TYPE.EXHAUSTION)
					$Sprite2D.texture = DEAD
				return
		# If it's not a rock or the rock can't move:
		# cancel movement completely
		#print("Cancelling movement....")
		return

	# If no collision -> move normally
	#print("Moving normally by: " + str(motion))
	translate(motion)


# Utility to check for contact even when stationary
func is_touching_boulder() -> bool:
	var shape_node = $CollisionShape2D
	if not shape_node or not shape_node.shape:
		return false

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = shape_node.shape
	params.transform = shape_node.global_transform
	params.collision_mask = collision_mask
	params.margin = 2.0 # Detect objects within 2 pixels
	params.exclude = [self.get_rid()] # Don't detect self
	
	var results = get_world_2d().direct_space_state.intersect_shape(params)
	
	for result in results:
		if result.collider is Boudler:
			return true
	return false

# To be called by Main, not from within the player
func evolve():
	if phase < PHASES.primate:
		phase += 1
		apply_phase_traits()
		apply_new_textures()

func apply_new_textures():
	match phase:
		PHASES.fish:
			LEFT = FISH_LEFT
			LEFT_BACK = FISH_LEFT_BACK
			RIGHT = FISH_RIGHT
			RIGHT_BACK = FISH_RIGHT_BACK
			DEAD = FISH_DEAD
		PHASES.lizard:
			LEFT = LIZARD_LEFT
			LEFT_BACK = LIZARD_LEFT_BACK
			RIGHT = LIZARD_RIGHT
			RIGHT_BACK = LIZARD_RIGHT_BACK
			DEAD = LIZARD_DEAD
		PHASES.primate:
			LEFT = PRIMATE_LEFT
			LEFT_BACK = PRIMATE_LEFT_BACK
			RIGHT = PRIMATE_RIGHT
			RIGHT_BACK = PRIMATE_RIGHT_BACK
			DEAD = PRIMATE_DEAD
	update_sprite_direction(Vector2(1,1))

func apply_phase_traits():
	# Reset defaults
	AFFECTED_BY_WATER = true
	AFFECTED_BY_MUD = true
	match phase:
		PHASES.blob:
			can_drown_in_water = true
			AFFECTED_BY_MUD_STUCK = true # Stuck fully
			AFFECTED_BY_MUD_SLOW = false
			print("Form: Blob (Drowns in water, Stuck in mud)")
			
		PHASES.fish:
			can_drown_in_water = false # Can breathe underwater
			AFFECTED_BY_MUD_STUCK = true # Still stuck in mud
			AFFECTED_BY_MUD_SLOW = false
			print("Form: Fish (Swims, Stuck in mud)")
			
		PHASES.lizard:
			can_drown_in_water = false 
			AFFECTED_BY_MUD_STUCK = false # Can move
			AFFECTED_BY_MUD_SLOW = true   # But slowed
			print("Form: Frog/Lizard (Resists water, Slowed in mud)")
			
		PHASES.primate:
			can_drown_in_water = false
			AFFECTED_BY_MUD_STUCK = false
			AFFECTED_BY_MUD_SLOW = true
			print("Form: Primate")


func spawn(point):
	position = point
	stamina = max_stamina
	stamina_change.emit(stamina, false)
	
	drowning = false
	$DrowningTimer.stop()
	# Reset the sinking visual effect
	$Sprite2D.position = Vector2.ZERO
	$Sprite2D.material.set_shader_parameter("sink_y", 1000.0)

func _on_drowning_timer_timeout() -> void:
	death.emit(DEATH_TYPE.DROWNING)
	$Sprite2D.texture = DEAD
