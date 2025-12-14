extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

var attack_ip = false

@export var speed = 100

var direction = Vector2.ZERO
var last_dir = "down"



func _physics_process(delta):
	attack()
	enemy_attack()
	if health <= 0:
		player_alive = false
		health = 0
	direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left","ui_right")
	direction.y = Input.get_axis("ui_up","ui_down")
	direction = direction.normalized()
	
	velocity = direction * speed
	move_and_slide()
	
	_update_anim()

func _update_anim():
	if attack_ip:
		return
	var anim = ""
	
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_dir = "right" if direction.x > 0 else "left"
		else:
			last_dir = "down" if direction.y > 0 else "up"
		anim = "walk_" + last_dir
	else:
		if attack_ip == false:
			anim = "idle_" + last_dir
	
	$AnimatedSprite2D.play(anim) 

func player():
	pass

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true
		


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false
		
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health = health - 10
		print(health)
		enemy_attack_cooldown = false
		$attack_cooldown.start()


func _on_timer_timeout() -> void:
	enemy_attack_cooldown = true

func attack():
	if Input.is_action_just_pressed("attack") and attack_ip == false:
		attack_ip = true
		Global.player_current_attack = true
		
		$deal_attack_timer.start()
		
		match last_dir:
			"right":
				$AnimatedSprite2D.play("attack_right")
			"left":
				$AnimatedSprite2D.play("attack_left")
			"down":
				$AnimatedSprite2D.play("attack_down")
			"up":
				$AnimatedSprite2D.play("attack_up")


func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	Global.player_current_attack = false
	attack_ip = false
