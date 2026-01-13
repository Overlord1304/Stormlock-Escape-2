extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D


var speed := 60.0
var idle_speed := 40.0
var walk_time := 3.0
var idle_time := 4.0
var idle_direction := 1
var idle_timer := 0.0
var idle_walking := true


var player_chase := false
var force_idle := false
var storm: Area2D = null
var player: Node2D = null
var is_dead := false


var health := 80
var player_inattack_zone := false
var can_take_damage := true

signal died

func _physics_process(delta):
	update_health()
	deal_with_damage()

	if is_dead:
		return

	var desired_velocity := Vector2.ZERO

	if storm and is_instance_valid(storm):
		var away_dir = (global_position - storm.global_position).normalized()
		nav_agent.target_position = global_position + away_dir * 500

	
	elif player_chase and is_instance_valid(player):
		nav_agent.target_position = player.global_position

	
	else:
		idle_timer += delta

		if idle_walking and get_tree().current_scene.name != "help1":
			force_idle = false
			desired_velocity.x = idle_speed * idle_direction

			if idle_timer >= walk_time:
				idle_timer = 0.0
				idle_walking = false
				force_idle = true
		else:
			force_idle = true
			desired_velocity = Vector2.ZERO

			if idle_timer >= idle_time:
				idle_timer = 0.0
				idle_walking = true
				idle_direction *= -1
				force_idle = false

	
	if not nav_agent.is_navigation_finished():
		var next_point = nav_agent.get_next_path_position()
		var direction = (next_point - global_position).normalized()
		var final_speed := speed

		if player_chase and is_instance_valid(player):
			var dist = global_position.distance_to(player.global_position)
			var slow_radius := 48.0
			if dist < slow_radius:
				final_speed = speed * lerp(0.8, 1.0, dist / slow_radius)

		desired_velocity = direction * final_speed

	
	if force_idle and not player_chase and storm == null:
		velocity.x = 0

	var acceleration := 800.0
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	move_and_slide()

	
	if velocity.length() > 5:
		$AnimatedSprite2D.play("move")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.play("idle")


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_chase = true
		idle_timer = 0.0
		idle_walking = true
		force_idle = false

func _on_area_2d_body_exited(body):
	if body == player:
		player = null
		player_chase = false


func _on_hitbox_body_entered(body: Node2D):
	if body.has_method("player"):
		player_inattack_zone = true

func _on_hitbox_body_exited(body: Node2D):
	if body.has_method("player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack:
		if can_take_damage:
			if Global.damage_buff:
				health -= 40
			else:
				health -= 20
			can_take_damage = false
			$take_damage_cooldown.start()

			if health <= 0 and not is_dead:
				die()

func _on_take_damage_cooldown_timeout():
	can_take_damage = true


func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	healthbar.visible = health < 80


func die():
	is_dead = true
	player_chase = false
	can_take_damage = false

	$CollisionShape2D.disabled = true
	$hitbox/right.disabled = true
	$hitbox/left.disabled = true

	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("death")

func _on_animated_sprite_2d_animation_finished():
	if is_dead and $AnimatedSprite2D.animation == "death":
		Global.score += 20
		died.emit()
		queue_free()


func _on_storm_detector_area_entered(area: Area2D):
	if area.is_in_group("storm"):
		storm = area

func _on_storm_detector_area_exited(area: Area2D):
	if area == storm:
		storm = null
func enemy():
	pass
