extends CharacterBody2D

@export var attack_range := 96.0
@export var attack_damage := 10

var attack_chargeup = 0
var view_range = 256

var isLunging = false

var player: Node2D

const ATTACK_CHARGE_TIME = 3

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player:
		print("OH NO NO PLAYER HELP")
		return
		
	var dist = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()
	if dist <= view_range:
		rotation = direction.angle()
		if has_line_of_sight():
			attack_chargeup += delta
		else:
			attack_chargeup = 0
	else:
		attack_chargeup = 0
		
	if attack_chargeup > 1:
#		TODO: Play some animations as the chargeup is happening?
		pass 
	
	if attack_chargeup >= ATTACK_CHARGE_TIME:
		attack_player()
		attack_chargeup = 0

func attack_player():
	isLunging = true
	$LungeActiveTimer.start()
	lunge_to_player()
	
func lunge_to_player():
	var tween := create_tween()
	var target := player.global_position
	var direction := (target - global_position)
	var distanceFromPlayerCenter = 32

	var end_pos := global_position + direction - (direction.normalized() * int(distanceFromPlayerCenter))

	tween.tween_property(self, "global_position", end_pos, 0.80).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if isLunging && area.name == "PlayerHitBox":
		print("Hit player")
		player.die()
	if area.name == "BoulderHitBox":
		print("Hit Boulder")
		queue_free()


func has_line_of_sight() -> bool:
	var space := get_world_2d().direct_space_state

	var params := PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)

	params.exclude = [self, player]

	var result = space.intersect_ray(params)

	# If nothing was hit → clear line of sight
	if result.is_empty():
		return true

	# If the thing we hit IS the player → also clear line of sight
	return result["collider"] == player


func _on_lunge_active_timer_timeout() -> void:
	isLunging = false
