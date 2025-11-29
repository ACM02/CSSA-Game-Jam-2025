extends CharacterBody2D

@export var speed := 60.0
@export var attack_range := 96.0
@export var attack_damage := 10
@export var attack_cooldown := 1.0  # seconds

var player: Node2D
var time_since_attack := 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player:
		print("OH NO NO PLAYER HELP")
		return
		
	time_since_attack += delta
	
	var dist = global_position.distance_to(player.global_position)
	
	
	# If close enough → stop and attack
	if dist <= attack_range:
		velocity = Vector2.ZERO
		move_and_slide()
		
		if time_since_attack >= attack_cooldown:
			attack_player()
		return

	# Otherwise → chase
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func attack_player():
	time_since_attack = 0.0
	
	# Call player's damage function (we will add this next)
	if player.has_method("damage"):
		player.damage(attack_damage)
