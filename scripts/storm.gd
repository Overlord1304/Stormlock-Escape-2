extends Area2D
@export var speed: float = 5
var player_inside = null
var push_strength = 100
var start_position
func _ready() -> void:
	start_position = global_position
	$AnimatedSprite2D.play("default")


func _physics_process(delta: float):
	if not Global.storm_can_move:
		return
	if self.is_in_group("storm left"):
		position.x += speed * delta
	elif self.is_in_group("storm right"):
		position.x -= speed * delta


func _on_hitbox_body_entered(body) -> void:
	if body.is_in_group("player"):
		player_inside = body
		$DamageTimer.start()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body == player_inside:
		player_inside = null
		$DamageTimer.stop()



func _on_damage_timer_timeout() -> void:
	if player_inside:
		player_inside.health -= 20
		if player_inside.health <= 0:
			player_inside.die(player_inside.DeathType.STORM)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		_apply_push(body)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.storm_push = Vector2.ZERO

func _apply_push(enemy):
	var dir = (enemy.global_position - global_position).normalized()
	enemy.storm_push = dir * push_strength

func reset_storm():
	global_position = start_position
