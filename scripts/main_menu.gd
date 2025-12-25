extends Control

@onready var anim_player = $AnimationPlayer

var is_transitioning := false

func _ready():
	$leftstorm.play("default")
	$rightstorm.play("default")
	$MusicPlayer.play()

func _on_play_button_pressed() -> void:
	if is_transitioning:
		return

	is_transitioning = true

	anim_player.play("stormclose")
	fade_out_music(2.0)

	var anim_name = await anim_player.animation_finished
	if anim_name == "stormclose":
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func fade_out_music(duration):
	var tween = get_tree().create_tween()
	tween.tween_property($MusicPlayer, "volume_db", -80, duration)
	tween.tween_callback($MusicPlayer.stop)
