extends Sprite2D
func reset_and_show():
	modulate.a = 1.0
	show()

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(hide)
	
