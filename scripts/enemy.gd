extends CharacterBody2D
@onready var nav_agent = $NavigationAgent2D
var storm = null
var storm_avoid_distance = 120
var speed = 60
var player_chase = false
var player = null
var health = 80
var player_inattack_zone = false
var can_take_damage = true
var is_dead = false
signal died
func _physics_process(delta):
	update_health()
	deal_with_damage()

	if is_dead:
		return

	var target_position = null

	# PRIORITY 1: RUN AWAY FROM STORM
	if storm:
		var away_dir = (global_position - storm.global_position).normalized()
		target_position = global_position + away_dir * 200

	# PRIORITY 2: CHASE PLAYER
	elif player_chase and player:
		target_position = player.global_position

	if target_position:
		nav_agent.target_position = target_position

		var next_point = nav_agent.get_next_path_position()
		var direction = (next_point - global_position).normalized()

		velocity = direction * speed
		move_and_slide()

		$AnimatedSprite2D.play("move")
		$AnimatedSprite2D.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		$AnimatedSprite2D.play("idle")

func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("player"):
		player = body
		player_chase = true

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group("player"):
		player = null
		player_chase = false

func enemy():
	pass


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false
		
func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			health -= 20
			$take_damage_cooldown.start()
			can_take_damage = false
			if health <= 0 and not is_dead:
				die()
				return



func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	if health >= 80:
		healthbar.hide()
	else:
		healthbar.show()

func die():
	is_dead = true
	player_chase = false
	can_take_damage = false
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("death")
	$hitbox/right.disabled = true
	$hitbox/left.disabled = true
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_dead and $AnimatedSprite2D.animation == "death":
		Global.score += 20
		died.emit()
		queue_free()


func _on_storm_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("storm"):
		storm = body


func _on_storm_detector_body_exited(body: Node2D) -> void:
	if body == storm:
		storm = null
