extends CharacterBody2D

var speed = 50
var health = 100

var river_tilemap: TileMapLayer
const RIVER_ATLAS_COORDINATES = Vector2i(7, 8)
const RIVER_FLOW = Vector2(-1, 1)       # flowing down
const RIVER_SPEED = 0.5                 # tweak as needed


signal health_change(new_health)
signal death

func _ready() -> void:
	health_change.emit(100)
	river_tilemap = get_tree().get_first_node_in_group("ground")

func damage(amount: int):
	print("Player took " + str(amount) + " damage!")
	health -= amount
	health_change.emit(health)
	if (health <= 0):
		print("Player died of death")
		death.emit()

func _physics_process(delta):
	var input_vec = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	var motion = input_vec * speed * delta
	motion = apply_river_current(motion, delta)
	#print("Final player direction: " + str(motion))
	# Try move using test_move, not move_and_collide
	if motion != Vector2.ZERO:
		try_move(motion)

func apply_river_current(direction, delta) -> Vector2:
	var tile = river_tilemap.local_to_map(river_tilemap.to_local(global_position))
	var id = river_tilemap.get_cell_source_id(tile)
	var tile_pos = river_tilemap.local_to_map(river_tilemap.to_local(global_position))
	var atlas = river_tilemap.get_cell_atlas_coords(tile_pos)

	if atlas == RIVER_ATLAS_COORDINATES:
		direction += RIVER_FLOW * RIVER_SPEED
		#print("Direction after river flow: " + str(direction))
	return direction

func try_move(motion: Vector2):
	#print("Trying to move: " + str(motion))
	var space = get_world_2d().direct_space_state
	var collision = move_and_collide(motion)

	if collision:
		var collider = collision.get_collider()

		if collider is Rock:
			# attempt push
			if collider.try_push(motion):
				# move player again after push
				translate(motion)
				return
		if collider is Boudler:
			if collider.try_push(motion):
				translate(motion)
				return
		# If it's not a rock or the rock can't move:
		# cancel movement completely
		#print("Cancelling movement....")
		return

	# If no collision -> move normally
	#print("Moving normally by: " + str(motion))
	translate(motion)
