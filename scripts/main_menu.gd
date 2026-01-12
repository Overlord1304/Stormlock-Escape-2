extends Control
var saves = "user://saves.save"
var dialogue_seen = false
@onready var anim_player = $AnimationPlayer
@onready var dialogue_box = $Control

var dialogue = [
	{"text": "Welcome to Stormlock Escape 2 where you defeat enemies that come in waves. Click the help menu for instructions :)"},
]
var is_transitioning := false

func _ready():
	_load_save()
	dialogue_help()
	$leftstorm.play("default")
	$rightstorm.play("default")
	$MusicPlayer.play()
func _load_save():
	if FileAccess.file_exists(saves):
		var file = FileAccess.open(saves,FileAccess.READ)
		var data = file.get_var()
		dialogue_seen = data.get("dialogue_seen",false)
		file.close()
func _save():
	var file = FileAccess.open(saves,FileAccess.WRITE)
	file.store_var({"dialogue_seen": dialogue_seen})
	file.close()
func dialogue_help():
	if !dialogue_seen:
		dialogue_box.start_dialogue(dialogue)
		dialogue_seen = true
		_save()
	else:
		return
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


func _on_help_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/help1.tscn")
