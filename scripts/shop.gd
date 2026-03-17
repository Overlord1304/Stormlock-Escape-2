extends Control

@onready var coins_label = $Panel/coins
func _ready():
	Global.load_game()
func _process(delta: float) -> void:
	coins_label.text = "Coins: " + str(Global.coins)
	
	$Panel/atk/upgbar.frame = Global.atkupgbar
	$Panel/def/upgbar.frame = Global.defupgbar
	$Panel/agi/upgbar.frame = Global.agiupgbar
	
func _on_atkupg_button_down() -> void:
	if Global.coins >= Global.atkupg_cost:
		Global.coins -= Global.atkupg_cost
		Global.atkupg_cost *= 2
		Global.atk_upg *= 1.05
		Global.atkupgbar += 1
		Global.save_game()
		


func _on_defupg_button_down() -> void:
	if Global.coins >= Global.defupg_cost:
		Global.coins -= Global.defupg_cost
		Global.defupg_cost *= 2
		Global.def_upg *= 1.15
		Global.defupgbar += 1
		Global.save_game()


func _on_agiupg_button_down() -> void:
	if Global.coins >= Global.agiupg_cost:
		Global.coins -= Global.agiupg_cost
		Global.agiupg_cost *= 2
		Global.agi_upg *= 1.1
		Global.agiupgbar += 1
		Global.save_game()

		

func _on_button_2_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_button_3_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/shop2.tscn")
