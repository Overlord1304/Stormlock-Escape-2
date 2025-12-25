extends CharacterBody2D
@onready var nav_agent = $NavigationAgent2D
@onready var laser_ray = $LaserRay
@onready var laser_timer = $LaserRayTimer
@onready var warning_timer = $AttackWarningTimer
@onready var laser_area = $LaserArea
@onready var laser_shape_right = $LaserArea/right
@onready var laser_shape_left = $LaserArea/left
var idle_speed = 40
var walk_time = 3.0
var idle_time = 2.0
var idle_direction = 1
var idle_timer = 0.0
var idle_walking = true
var force_idle = false
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
var laser_active := false
var laser_has_hit_player := false


var warning_facing_right: bool = false

var laser_cooldown_timer: Timer
var can_fire_laser = true

signal died

func _ready():
	
	laser_cooldown_timer = Timer.new()
	laser_cooldown_timer.wait_time = 2.0 
	laser_cooldown_timer.one_shot = true
	laser_cooldown_timer.timeout.connect(_on_laser_cooldown_timeout)
	add_child(laser_cooldown_timer)

func _physics_process(delta):
	update_health()
	deal_with_damage()
	
	if is_dead:
		return
	
	
	if can_fire_laser and can_laser_damage and not is_attacking and not is_warning and player and can_see_player():
		start_warning()
	
	if is_warning or is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	
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
	else:
		idle_timer += delta
		if idle_walking:
			force_idle = false
			desired_velocity.x = idle_speed * idle_direction
			if idle_timer >= walk_time:
				idle_timer = 0.0
				idle_walking = false
				force_idle = true
		else:
			force_idle = true
			desired_velocity = Vector2.ZERO
			if idle_timer > idle_time:
				idle_timer = 0.0
				idle_walking = true
				idle_direction *= -1
				force_idle = false
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

	
	if not is_attacking and not is_warning:
		if velocity.length() > 5:
			$AnimatedSprite2D.play("move")
			$AnimatedSprite2D.flip_h = velocity.x < 0
		else:
			$AnimatedSprite2D.play("idle")

func start_warning():
	if is_dead or not can_fire_laser:
		return
	
	is_warning = true
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position
	
	
	warning_facing_right = not $AnimatedSprite2D.flip_h
	
	$AnimatedSprite2D.play("attack_warning")
	warning_timer.start(warning_time)

func laser_attack():
	if not can_laser_damage or is_dead or not can_fire_laser:
		return
	
	is_attacking = true
	can_fire_laser = false  
	
	
	if not warning_facing_right:  
		laser_shape_left.disabled = false
		laser_shape_right.disabled = true
		
		laser_ray.target_position = Vector2(-laser_range, 0)
		laser_ray.rotation = 0  
		$AnimatedSprite2D.flip_h = true 
	else:  
		laser_shape_right.disabled = false
		laser_shape_left.disabled = true
		laser_ray.target_position = Vector2(laser_range, 0)
		laser_ray.rotation = 0
		$AnimatedSprite2D.flip_h = false
	
	laser_active = true
	laser_has_hit_player = false
	laser_area.monitoring = true
	$LaserSound.play()

	laser_ray.force_raycast_update()

	laser_timer.start()

	for body in laser_area.get_overlapping_bodies():
		if body.is_in_group("player") and not laser_has_hit_player:
			if body.has_method("take_laser_damage"):
				body.take_laser_damage(laser_damage)
				laser_has_hit_player = true
			break
func _on_laser_ray_timer_timeout():
	
	laser_active = false
	laser_area.monitoring = false
	laser_shape_right.disabled = true
	laser_shape_left.disabled = true
	
	
	laser_cooldown_timer.start()

func _on_laser_cooldown_timeout():
	
	can_fire_laser = true
	can_laser_damage = true

func _on_attack_warning_timer_timeout():
	if is_dead:
		return
	
	is_warning = false
	play_attack()
	laser_attack()

func _on_laser_area_body_entered(body: Node2D):
	if not laser_active or laser_has_hit_player or is_dead:
		return
	
	if body.is_in_group("player"):
		if body.has_method("take_laser_damage"):
			body.take_laser_damage(laser_damage)
			laser_has_hit_player = true

func play_attack() -> void:
	if is_attacking:
		return
	is_attacking = true
	$AnimatedSprite2D.play("attack")

func can_see_player() -> bool:
	if is_dead or not player:
		return false
	
	var vertical_diff = abs(player.global_position.y - global_position.y)
	var max_vertical_offset = 10.0  
	if vertical_diff > max_vertical_offset:
		return false
	
	
	var facing_right = not $AnimatedSprite2D.flip_h
	var facing_dir = Vector2.RIGHT if facing_right else Vector2.LEFT
	var horizontal_diff = player.global_position.x - global_position.x
	
	
	if (facing_dir.x > 0 and horizontal_diff < 0) or (facing_dir.x < 0 and horizontal_diff > 0):
		return false
	var temp_target = Vector2(laser_range, 0) if facing_right else Vector2(-laser_range, 0)
	var temp_rotation = laser_ray.rotation
	laser_ray.target_position = temp_target
	laser_ray.rotation = 0  
	laser_ray.force_raycast_update()
	
	var can_see = false
	if laser_ray.is_colliding():
		can_see = laser_ray.get_collider() == player
	
	
	laser_ray.rotation = temp_rotation
	
	return can_see


func enemy():
	pass

func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("player"):
		player = body
		player_chase = true

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group("player"):
		player_chase = false

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
	$CollisionShape2D.disabled = true
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
