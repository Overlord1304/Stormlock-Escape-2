extends CharacterBody2D
@onready var nav_agent = $NavigationAgent2D
var idle_speed = 40
var walk_time = 3.0
var idle_time = 2.0
var idle_direction = 1
var idle_timer = 0.0
var idle_walking = true
var force_idle = false
var storm = null
var storm_avoid_distance = 120
var speed = 80
var player_chase = false
var player = null
var health = 50
var player_inattack_zone = false
var can_take_damage = true
var is_dead = false


signal died
func _physics_process(delta):
	update_health()
	deal_with_damage()

	if is_dead:
		return

	var desired_velocity := Vector2.ZERO
	if storm:
		var away_dir = (global_position - storm.global_position).normalized()
		nav_agent.target_position = global_position + away_dir * 500

	elif player_chase and player:
		nav_agent.target_position = player.global_position
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
			if Global.damage_buff:
				health -= 40
			else:
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
	if health >= 50:
		healthbar.hide()
	else:
		healthbar.show()

func die():
	$CollisionShape2D.disabled = true
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

func _on_storm_detector_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("storm"):
		
		storm = area


func _on_storm_detector_area_exited(area: Area2D) -> void:

	if area == storm:
		
		storm = null
