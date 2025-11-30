extends "physics_entity.gd"

var speed = 50
var health = 100

# Stamina System
var max_stamina: float = 100.0
var stamina: float = 100.0
var stamina_drain_rate = 30.0
var stamina_regen_rate = 15.0
var is_pushing: bool = false

signal health_change(new_health)
signal stamina_change(new_stamina, is_colliding)
signal death

func _ready() -> void:
	super._ready()
	health_change.emit(100)
	stamina_change.emit(100, false)
	AFFECTED_BY_RAMP=false

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
	motion += (get_physics_effects() * delta)
	
	# Reset pushing state for this frame; it will be set true in try_move if we push
	is_pushing = false
	
	#print("Final player direction: " + str(motion))
	# Try move using test_move, not move_and_collide
	if motion != Vector2.ZERO:
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
					death.emit()
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
