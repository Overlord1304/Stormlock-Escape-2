extends CharacterBody2D
@onready var nav_agent = $NavigationAgent2D
@onready var laser_ray = $LaserRay
@onready var laser_timer = $LaserRayTimer
@onready var warning_timer =  $AttackWarningTimer
var is_warning = false
var warning_time = 1
var laser_damage = 30
var laser_range = 100000
var can_laser_damage = true
var storm = null
var storm_avoid_distance = 120
var speed = 60
var player_chase = false
var player = null
var health = 100
var player_inattack_zone = false
var can_take_damage = true
var is_dead = false
var is_attacking = false

signal died
func _ready():
	if $AnimatedSprite2D.flip_h:
		$LaserRay.rotation = PI
	else:
		$LaserRay.rotation = 0
func _physics_process(delta):
	update_health()
	deal_with_damage()
	if can_laser_damage and not is_attacking and not is_warning and player and can_see_player():
		start_warning()
	if is_dead:
		return
	if is_warning or is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	else:
		
		var desired_velocity := Vector2.ZERO
		if storm:
			var away_dir = (global_position - storm.global_position).normalized()
			nav_agent.target_position = global_position + away_dir * 500

		elif player_chase and player:
			var dx = abs(player.global_position.x - global_position.x)
			var dy = abs(player.global_position.y - global_position.y)
			
			if dx > dy:
				nav_agent.target_position = Vector2(
					player.global_position.x,
					global_position.y
				)
			else:
				nav_agent.target_position = Vector2(
					global_position.x,
					player.global_position.y
				)


		if not nav_agent.is_navigation_finished():
			var next_point = nav_agent.get_next_path_position()
			var direction = (next_point - global_position).normalized()
			var final_speed = speed

			if player_chase and player:
				var dist = global_position.distance_to(player.global_position)

		
				var slow_radius := 48.0

				if dist < slow_radius:
					var t = dist / slow_radius
					final_speed = speed * lerp(0.8, 1.0, t)

			desired_velocity = direction * final_speed

		
		var acceleration := 800.0
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)

		move_and_slide()

		if not is_attacking:
			if velocity.length() > 5:
				$AnimatedSprite2D.play("move")
				$AnimatedSprite2D.flip_h = velocity.x < 0
			else:
				$AnimatedSprite2D.play("idle")
func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("player"):
		player = body
		player_chase = true

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group("player"):
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
	if health >= 100:
		healthbar.hide()
	else:
		healthbar.show()

func die():
	is_dead = true
	player_chase = false
	can_take_damage = false
	$LaserRayTimer.stop()
	$AttackWarningTimer.stop()
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("death")
	$hitbox/hitbox.disabled = true
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking and $AnimatedSprite2D.animation == "attack":
		is_attacking = false

	if is_dead and $AnimatedSprite2D.animation == "death":
		Global.score += 20
		died.emit()
		queue_free()

func _on_storm_detector_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("storm"):
		
		storm = area


func _on_storm_detector_area_exited(area: Area2D) -> void:

	if area == storm:
		
		storm = null
func play_attack() -> void:
	if is_attacking:
		return
	is_attacking = true
	$AnimatedSprite2D.play("attack")
func can_see_player() -> bool:
	if is_dead:
		return false

	
	var vertical_diff = abs(player.global_position.y - global_position.y)
	var max_vertical_offset = 10.0  
	if vertical_diff > max_vertical_offset:
		return false


	var facing_dir = Vector2.RIGHT if not $AnimatedSprite2D.flip_h else Vector2.LEFT
	var horizontal_diff = player.global_position.x - global_position.x
	if (facing_dir.x > 0 and horizontal_diff < 0) or (facing_dir.x < 0 and horizontal_diff > 0):
		return false

	
	$LaserRay.target_position = facing_dir * laser_range
	$LaserRay.force_raycast_update()


	if $LaserRay.is_colliding():
		return $LaserRay.get_collider() == player

	return false
func start_warning():
	if is_dead:
		return
	is_warning = true
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position
	$AnimatedSprite2D.play("attack_warning")
	warning_timer.start(warning_time)
func laser_attack():
	
	if not can_laser_damage or is_dead:
		return
	can_laser_damage = false
	laser_timer.start()
	
	player.take_laser_damage(laser_damage)
	
func _on_laser_ray_timer_timeout() -> void:
	if is_dead:
		return
	can_laser_damage = true


func _on_attack_warning_timer_timeout() -> void:
	if is_dead:
		return
	is_warning = false
	play_attack()
	if can_see_player():
		laser_attack()
