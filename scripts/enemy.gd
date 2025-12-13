extends CharacterBody2D

var speed = 60
var player_chase = false
var player = null

func _physics_process(delta) -> void:
	if player_chase and player:
		var to_player = player.position - position
		var distance = to_player.length()

		
		var slow_factor = clamp(distance / 80.0, 0.3, 1.0)
		var direction = to_player.normalized()

		move_and_collide(direction * speed * slow_factor * delta)

		$AnimatedSprite2D.play("move")
		$AnimatedSprite2D.flip_h = direction.x < 0
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
