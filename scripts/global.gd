extends Node

var player_current_attack = false
var score = 0
var high_score = 0
var player_died = false
var storm_can_move = false
var damage_buff = false
var shield_buff = false
var coins = 0
var atkupg_cost = 10
var defupg_cost = 10
var agiupg_cost = 10
var speed_upg = 1
var damage_upg = 1
var shield_upg = 1
func save_game():
	var data = {
		"high_score": high_score,
		"coins": coins,
		"atkupg_cost": atkupg_cost,
		"defupg_cost": defupg_cost,
		"agiupg_cost": agiupg_cost,
		"speed_upg": speed_upg,
		"damage_upg": damage_upg,
		"shield_upg": shield_upg
	}
	var file = FileAccess.open("user://save_data.save", FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_game():
	var saves = "user://save_data.save"
	if FileAccess.file_exists(saves):
		var file = FileAccess.open(saves, FileAccess.READ)
		var data = file.get_var()
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			high_score = data.get("high_score",0)
			coins = data.get("coins",0)
			atkupg_cost = data.get("atkupg_cost",10)
			defupg_cost = data.get("defupg_cost",10)
			agiupg_cost = data.get("agiupg_cost",10)
			speed_upg = data.get("speed_upg",1)
			damage_upg = data.get("damage_upg",1)
			shield_upg = data.get("shield_upg",1)
	else:
		save_game()
		
