extends Area2D



func _ready():
	$AnimatedSprite2D.play("default")
func collect():
	var tween = create_tween()
	tween.tween_property(self,"modulate:a",0.0,0.5)
	tween.tween_callback(Callable(self,"queue_free"))


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.on_food_collected()
		collect()
