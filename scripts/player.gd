extends "physics_entity.gd"

var speed = 50
var health = 100

var drowning = false

signal health_change(new_health)
signal death

enum PHASES {
	blob = 0,
	fish = 1,
	lizard = 2,
	primate = 3
}

@onready var phase = PHASES.blob

func _ready() -> void:
	super._ready()
	health_change.emit(100)
	AFFECTED_BY_RAMP=false

func damage(amount: int):
	print("Player took " + str(amount) + " damage!")
	health -= amount
	health_change.emit(health)
	if (health <= 0):
		print("Player died of death")
		death.emit()

func _physics_process(delta):
	super._physics_process(delta)
	var motion = Vector2.ZERO
	if phase < PHASES.fish && not drowning && isInWater():
		drowning = true
		$DrowningTimer.start()
	
	if not drowning:
		var input_vec = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized()
		motion = input_vec * speed * delta
		
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

# To be called by Main, not from within the player
func evolve():
	if phase < PHASES.primate:
		phase += 1
	if (phase == PHASES.fish):
		AFFECTED_BY_WATER = false
		print("Became fish")
	if (phase == PHASES.lizard):
		AFFECTED_BY_MUD = false
		mudCounter = 0

func spawn(point):
	position = point

func _on_drowning_timer_timeout() -> void:
	death.emit()
	drowning = false
