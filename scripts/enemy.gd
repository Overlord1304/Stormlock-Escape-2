extends CharacterBody2D
var storm_push = Vector2.ZERO
var storm_push_strength = 100
var speed = 60
var player_chase = false
var player = null
var health = 80
var player_inattack_zone = false
var can_take_damage = true
var is_dead = false
signal died
func _physics_process(delta) -> void:

	update_health()
	deal_with_damage()
	if is_dead:
		return
	if player_chase and player:
		var to_player = player.position - position
		var distance = to_player.length()

		
		var slow_factor = clamp(distance / 80.0, 0.3, 1.0)
		var direction = to_player.normalized()

		move_and_collide(direction * speed * slow_factor * delta)

		$AnimatedSprite2D.play("move")
		$AnimatedSprite2D.flip_h = direction.x < 0
		if $AnimatedSprite2D.flip_h == true:
			$hitbox/left.disabled = false
			$hitbox/right.disabled = true
		else:
			$hitbox/left.disabled = true
			$hitbox/right.disabled = false
	else:
		$AnimatedSprite2D.play("idle")
	velocity += storm_push
	storm_push = Vector2.ZERO
	move_and_slide()

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
