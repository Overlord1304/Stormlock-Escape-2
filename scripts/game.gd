extends Node2D

@onready var score_label = $ui/ScoreLabel
@onready var high_score_label = $ui/HighScoreLabel
@onready var countdown_label = $ui/CountdownLabel
var has_saved = false
var countdown_time = 3
var countdown_active = true
@onready var player = $player
func _ready():
	start_countdown()
	load_high_score()
	Global.score = 0
	Global.player_died = false

func _process(delta) -> void:
	if not Global.player_died:
		check_high_score()
		score_label.text = "Score: " + str(Global.score)
		high_score_label.text = "High Score: " + str(Global.high_score)
	else:
		if not has_saved:
			save_high_score()
			has_saved = true
func load_high_score():
	var high_score_saves = "user://high_score_saves.save"
	if FileAccess.file_exists(high_score_saves):
		var file = FileAccess.open(high_score_saves,FileAccess.READ)
		Global.high_score = int(file.get_as_text())
		file.close()

func check_high_score():
	if Global.score > Global.high_score:
		Global.high_score = Global.score
		
func save_high_score():
	var high_score_saves = "user://high_score_saves.save"
	var file = FileAccess.open(high_score_saves,FileAccess.WRITE)
	file.store_string(str(Global.high_score))
	file.close()
func start_countdown():
	countdown_label.show()

	for i in range(countdown_time, 0, -1):
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "Go!"
	
	countdown_label.hide()

	player.can_move = true
	Global.storm_can_move = true


func _on_timer_lightning_timeout() -> void:
	player.speed = 100
