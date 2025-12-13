extends CharacterBody2D

@export var speed = 100

var direction = Vector2.ZERO
var last_dir = "down"



func _physics_process(delta):
	direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left","ui_right")
	direction.y = Input.get_axis("ui_up","ui_down")
	direction = direction.normalized()
	
	velocity = direction * speed
	move_and_slide()
	
	_update_anim()

func _update_anim():
	var anim = ""
	
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_dir = "right" if direction.x > 0 else "left"
		else:
			last_dir = "down" if direction.y > 0 else "up"
		anim = "walk_" + last_dir
	else:
		anim = "idle_" + last_dir
	
	$AnimatedSprite2D.play(anim) 
