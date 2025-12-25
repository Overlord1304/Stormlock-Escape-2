extends CharacterBody2D
enum DeathType {
	SLIME,
	NORMAL,
	MECH,
	STORM
}
var step_timer = 0.0
var step_interval = 0.35
var enemy_inattack_range = false
var psb_inattack_range = false
var crab_inattack_range = false
var mech_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var can_move = false
var crab = null
var mech = null
var attack_ip = false
var was_moving = false
@onready var speed = 100

var direction = Vector2.ZERO
var last_dir = "down"


func _ready():
	$AnimatedSprite2D.play("idle_down")
func _physics_process(delta):
	attack()
	enemy_attack()
	psb_attack()
	update_health()
	if crab_inattack_range:
		crab.play_attack()
	if health <= 0:
		if crab_inattack_range:
			die(DeathType.NORMAL)
		else:
			die(DeathType.SLIME)
		return
	if !can_move:
		return
	direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left","ui_right")
	direction.y = Input.get_axis("ui_up","ui_down")
	direction = direction.normalized()
	
	velocity = direction * speed
	move_and_slide()
	handle_footsteps(delta)
	_update_anim()
func handle_footsteps(delta):
	if !can_move or attack_ip or health <= 0:
		$footsteps.stop()
		step_timer = 0.0
		was_moving = false
		return
	var is_moving = direction != Vector2.ZERO
	if is_moving and !was_moving:
		play_footstep()
		step_timer = 0.0
	if is_moving:
		step_timer += delta
		if step_timer >= step_interval:
			play_footstep()
			step_timer = 0.0
	else:
		step_timer = 0.0
	was_moving = is_moving
func play_footstep():
	$footsteps.pitch_scale = randf_range(0.9, 1.1)
	$footsteps.stop()
	$footsteps.play()
func _update_anim():
	if attack_ip or health == 0:
		return
	var anim = ""
	
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_dir = "right" if direction.x > 0 else "left"
		else:
			last_dir = "down" if direction.y > 0 else "up"
		$right.disabled = last_dir != "right"
		$left.disabled = last_dir != "left"
		$up.disabled = last_dir != "up"
		$down.disabled = last_dir != "down"
		anim = "walk_" + last_dir
	else:
		if attack_ip == false:
			anim = "idle_" + last_dir
	
	$AnimatedSprite2D.play(anim) 

func player():
	pass

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		if body.has_method("start_charge"):
			psb_inattack_range = true
		else:
			if body.is_in_group("crab"):
				crab_inattack_range = true
				crab = body
			elif body.is_in_group("mech"):
				mech_inattack_range = true
				mech = body
				
			enemy_inattack_range = true



func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		if body.has_method("start_charge"):
			psb_inattack_range = false
		else:
			if body.is_in_group("crab"):
				crab_inattack_range = false
				crab = null
			elif body.is_in_group("mech"):
				mech_inattack_range = false
				mech = null
				
			enemy_inattack_range = false
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health = health - 10
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		if health <= 0:
			if crab_inattack_range or mech_inattack_range:
				die(DeathType.NORMAL)
			else:
				die(DeathType.SLIME)
func psb_attack():
	if psb_inattack_range and enemy_attack_cooldown == true:
		health = health - 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		if health <= 0:
			die(DeathType.NORMAL)
func take_laser_damage(amount):
	health -= amount
	update_health()

	if health <= 0:
		die(DeathType.MECH)
func _on_timer_timeout() -> void:
	
	enemy_attack_cooldown = true

func attack():
	if Input.is_action_just_pressed("attack") and attack_ip == false:
		attack_ip = true
		Global.player_current_attack = true
		$attack.stop()
		$attack.pitch_scale = randf_range(0.95,1.05)
		$attack.play()
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

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	
	if health >= 100:
		healthbar.hide()
		health = 100
	else:
		healthbar.show()
func die(death_type: DeathType):
	if Global.player_died:
		return

	Global.player_died = true
	health = 0
	update_health()
	velocity = Vector2.ZERO

	set_process(false)
	set_physics_process(false)
	match death_type:
		DeathType.SLIME:
			$AnimatedSprite2D.play("slime_death_" + last_dir)
		DeathType.NORMAL:
			$AnimatedSprite2D.play("enemy_death_" + last_dir)
		DeathType.STORM:
			$AnimatedSprite2D.play("storm_death_" + last_dir)
		DeathType.MECH:
			$AnimatedSprite2D.play("mech_death_" + last_dir) 
	await $AnimatedSprite2D.animation_finished
	get_tree().reload_current_scene()


func on_food_collected() -> void:
	health += 50
	update_health()
