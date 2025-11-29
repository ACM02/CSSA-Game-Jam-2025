extends "physics_entity.gd"

var speed = 50
var health = 100

signal health_change(new_health)
signal death

func _ready() -> void:
	super._ready()
	health_change.emit(100)

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
	#print("Final player direction: " + str(motion))
	# Try move using test_move, not move_and_collide
	if motion != Vector2.ZERO:
		try_move(motion)

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
