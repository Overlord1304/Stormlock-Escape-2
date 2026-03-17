extends Node2D
@onready var pause_menu = $player/CanvasLayer/pause
@onready var score_label = $ui/score
@onready var high_score_label = $ui/highscore
@onready var countdown_label = $ui/countdown
@onready var coins_label =$ui/coins
var countdown_time = 3

@onready var player = $player
func _ready():
	get_tree().paused = false
	start_countdown()
	Global.load_game()
	Global.score = 0
	Global.player_died = false
	$TimerShield.wait_time *= Global.def_upg
func _process(delta) -> void:
	if not Global.player_died:
		check_high_score()
		Global.save_game()
		score_label.text = "Score: " + str(Global.score)
		high_score_label.text = "High Score: " + str(Global.high_score)
		coins_label.text = "Coins: " + str(Global.coins)

func _input(event):
	if event.is_action_pressed("pause") and player.can_move:
		pause_game()
func pause_game():
	get_tree().paused= true
	pause_menu.show()
func check_high_score():
	if Global.score > Global.high_score:
		Global.high_score = Global.score
		

func start_countdown():
	countdown_label.show()

	for i in range(countdown_time, 0, -1):
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	
	countdown_label.hide()

	player.can_move = true
	Global.storm_can_move = true


func _on_timer_lightning_timeout() -> void:
	player.speed = 100
	$ui/lightning.fade_out()
	

func _on_timer_damage_timeout() -> void:
	Global.damage_buff = false
	$ui/sword.fade_out()
func _on_timer_shield_timeout() -> void:
	Global.shield_buff = false
	$ui/shield.fade_out()
