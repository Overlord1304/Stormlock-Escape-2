extends Control



func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/help1.tscn")


func _on_button_2_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	


func _on_button_3_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/help3.tscn")
