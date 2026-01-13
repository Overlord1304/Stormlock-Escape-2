extends Sprite2D
func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(hide)
	
