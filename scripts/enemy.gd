extends CharacterBody2D

@export var attack_range := 96.0
@export var attack_damage := 10

var attack_chargeup = 0
var view_range = 256

var isLunging = false
var lungePoint = null
var player: Node2D

const ATTACK_CHARGE_TIME = 3
const LUNGE_POSITION_DESCISION_TIME = 1

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player:
		print("OH NO NO PLAYER HELP")
		return
		
	var dist = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()
	if dist <= view_range:
		if not lungePoint:
			rotation = direction.angle()
		else:
			rotation = (global_position - lungePoint).angle() - PI
		if has_line_of_sight():
			attack_chargeup += delta
		else:
			attack_chargeup = 0
			lungePoint = null
	else:
		attack_chargeup = 0
		lungePoint = null
		
	if not lungePoint && attack_chargeup > LUNGE_POSITION_DESCISION_TIME:
		lungePoint = player.global_position
		show_lunge_point(lungePoint)
	
	if attack_chargeup >= ATTACK_CHARGE_TIME:
		attack_player()
		attack_chargeup = 0

func attack_player():
	isLunging = true
	$LungeActiveTimer.start()
	lunge_to_player()
	
func lunge_to_player():
	var tween := create_tween()
	
	# Calculate duration based on speed of 200 px/sec
	var dist = global_position.distance_to(lungePoint)
	var duration = dist / 200.0

	tween.tween_property(self, "global_position", lungePoint, 0.80).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	lungePoint = null


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

@export var lunge_point_effect_scene: PackedScene

func show_lunge_point(lunge_point: Vector2) -> void:
	if not lunge_point_effect_scene:
		return # safety check

	print("Showing lunge point")
	var effect_instance = lunge_point_effect_scene.instantiate()
	effect_instance.global_position = lunge_point
	get_tree().current_scene.add_child(effect_instance)
