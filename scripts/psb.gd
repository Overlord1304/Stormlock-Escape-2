extends CharacterBody2D
@onready var nav_agent = $NavigationAgent2D
var idle_speed = 40
var walk_time = 3.0
var idle_time = 2.0
var idle_direction = 1
var idle_timer = 0.0
var idle_walking = true
var force_idle = false
var speed = 40
var player_chase = false
var player = null
var health = 200
var player_inattack_zone = false
var can_take_damage = true
var is_dead = false
var is_charging = false
var charge_speed = 150
var charge_time = 0.5
var charge_cooldown = 3.0
var charge_timer = 0.0
var charge_direction = Vector2.ZERO
signal died
func _physics_process(delta):
	update_health()
	deal_with_damage()

	if is_dead:
		return

	if is_charging:
		
		if player:
		
			charge_direction = (player.global_position - global_position).normalized()
		velocity = charge_direction * charge_speed
		move_and_slide()
		$AnimatedSprite2D.play("move")
		$AnimatedSprite2D.flip_h = velocity.x < 0
		charge_timer -= delta
		if charge_timer <= 0:
			end_charge()
		return
	else:
		charge_timer -= delta
		if charge_timer <= 0:
			start_charge()

	var desired_velocity := Vector2.ZERO

	if player_chase and player:
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

	if player_chase and player:
		if nav_agent.is_navigation_finished():
			
			var direction = (player.global_position - global_position).normalized()
			desired_velocity = direction * speed
		else:
			var next_point = nav_agent.get_next_path_position()
			var direction = (next_point - global_position).normalized()

			var dist = global_position.distance_to(player.global_position)
			var slow_radius := 48.0
			var final_speed = speed
			if dist < slow_radius:
				final_speed = speed * (dist / slow_radius)

			desired_velocity = direction * final_speed

	var acceleration := 800.0
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	move_and_slide()

	if velocity.length() > 5:
		$AnimatedSprite2D.play("move")
		$AnimatedSprite2D.flip_h = velocity.x < 0
		if $AnimatedSprite2D.flip_h:
			$hitbox/left.disabled = false
			$hitbox/right.disabled = true
			$left.disabled = false
			$right.disabled = true
		else:
			$hitbox/left.disabled = true
			$hitbox/right.disabled = false
			$left.disabled = true
			$right.disabled = false
	else:
		$AnimatedSprite2D.play("idle")


func start_charge():
	if player:
		charge_direction = (player.global_position - global_position).normalized()
	else:
		charge_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	is_charging = true
	charge_timer = charge_time

func end_charge():
	is_charging = false
	charge_timer = charge_cooldown

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
	if health >= 200:
		healthbar.hide()
	else:
		healthbar.show()

func die():
	$left.disabled = true
	$right.disabled = true
	is_dead = true
	player_chase = false
	can_take_damage = false
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("death")
	$hitbox/right.disabled = true
	$hitbox/left.disabled = true
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_dead and $AnimatedSprite2D.animation == "death":
		Global.score += 100
		died.emit()
		queue_free()
