extends Control

@onready var coins_label = $Panel/coins
func _ready():
	Global.load_game()

func _process(delta: float) -> void:
	coins_label.text = "Coins: "+ str(Global.coins)
	$Panel/dmg/upgbar.frame = Global.dmgupgbar
	$Panel/food/upgbar.frame = Global.foodupgbar
	$Panel/spd/upgbar.frame = Global.spdupgbar


func _on_dmgupg_button_down() -> void:
	if Global.coins >= Global.dmgupg_cost:
		Global.coins -= Global.dmgupg_cost
		Global.dmgupg_cost*= 2
		Global.dmg_upg *= 1.05
		Global.dmgupgbar += 1
		Global.save_game()



func _on_foodupg_button_down() -> void:
	if Global.coins >= Global.foodupg_cost:
		Global.coins -= Global.foodupg_cost
		Global.foodupg_cost *= 2
		Global.food_upg += 1.05
		Global.foodupgbar += 1
		Global.save_game()


func _on_spdupg_button_down() -> void:
	if Global.coins >= Global.spdupg_cost:
		Global.coins -= Global.spdupgbar
		Global.spdupgbar *= 2
		Global.spd_upg += 1.02
		Global.spdupgbar += 1
		Global.save_game()


func _on_button_3_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/shop1.tscn")
