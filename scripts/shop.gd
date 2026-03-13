extends Control

@onready var coins_label = $Panel/coins
func _ready():
	Global.load_game()
func _process(delta: float) -> void:
	coins_label.text = "Coins: " + str(Global.coins)

func _on_atkupg_button_down() -> void:
	if Global.coins >= Global.atkupg_cost:
		Global.coins -= Global.atkupg_cost
		Global.atkupg_cost *= 2
		Global.damage_upg *= 1.05
		Global.save_game()
		$Panel/atk/upgbar.frame += 1


func _on_defupg_button_down() -> void:
	if Global.coins >= Global.defupg_cost:
		Global.coins -= Global.defupg_cost
		Global.defupg_cost *= 2
		Global.shield_upg *= 1.15
		Global.save_game()
		$Panel/def/upgbar.frame += 1


func _on_agiupg_button_down() -> void:
	if Global.coins >= Global.agiupg_cost:
		Global.coins -= Global.agiupg_cost
		Global.agiupg_cost *= 2
		Global.speed_upg *= 1.1
		Global.save_game()
		$Panel/agi/upgbar.frame += 1


func _on_button_2_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
