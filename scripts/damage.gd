extends Area2D

var collected := false

func _ready():
	$AnimatedSprite2D.play("default")

func collect():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if body.is_in_group("player"):
		collected = true
		body.on_damage_collected()
		$CollisionShape2D.set_deferred("disabled",true)
		collect()
