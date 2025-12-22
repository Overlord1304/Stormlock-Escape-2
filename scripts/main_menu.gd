extends Control
@onready var anim_player = $AnimationPlayer
func _ready():
	$leftstorm.play("default")
	$rightstorm.play("default")

func _on_play_button_pressed() -> void:
	anim_player.play("stormclose")
	while true:
		var anim_name = await anim_player.animation_finished
		if anim_name == "stormclose":
			break
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	anim_player.play("stormopen")
