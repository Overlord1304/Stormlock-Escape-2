extends CharacterBody2D

var speed = 60
var player_chase = false
var player = null
var health = 80
var player_inattack_zone = false
var can_take_damage = true

func _physics_process(delta) -> void:
	update_health()
	deal_with_damage()
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
			health = health - 20
			print(health)
			$take_damage_cooldown.start()
			can_take_damage = false
			if health <= 0:
				self.queue_free()


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	if health >= 80:
		healthbar.hide()
	else:
		healthbar.show()
