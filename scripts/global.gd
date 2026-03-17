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
var atkupgbar = 0
var defupgbar = 0
var agiupgbar = 0
var agi_upg = 1
var atk_upg = 1
var def_upg = 1
var dmgupg_cost = 10
var foodupg_cost = 10
var spdupg_cost = 10
var dmgupgbar = 0
var foodupgbar = 0
var spdupgbar = 0
var dmg_upg = 1
var food_upg = 1
var spd_upg = 1
func save_game():
	var data = {
		"high_score": high_score,
		"coins": coins,
		"atkupg_cost": atkupg_cost,
		"defupg_cost": defupg_cost,
		"agiupg_cost": agiupg_cost,
		"agi_upg": agi_upg,
		"atk_upg": atk_upg,
		"def_upg": def_upg,
		"atkupgbar": atkupgbar,
		"defupgbar": defupgbar,
		"agiupgbar": agiupgbar,
		"dmgupg_cost": dmgupg_cost,
		"foodupg_cost": foodupg_cost,
		"spdupg_cost": spdupg_cost,
		"spd_upg": spd_upg,
		"dmg_upg": dmg_upg,
		"food_upg": food_upg,
		"dmgupgbar": dmgupgbar,
		"foodupgbar": foodupgbar,
		"spdupgbar": spdupgbar
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
			agi_upg = data.get("agi_upg",1)
			atk_upg = data.get("atk_upg",1)
			def_upg = data.get("def_upg",1)
			atkupgbar = data.get("atkupgbar",0)
			defupgbar = data.get("defupgbar",0)
			agiupgbar = data.get("agiupgbar",0)
			dmgupg_cost = data.get("dmgupg_cost",10)
			foodupg_cost = data.get("foodupg_cost",10)
			spdupg_cost = data.get("spdupg_cost",10)
			spd_upg = data.get("spd_upg",1)
			dmg_upg = data.get("dmg_upg",1)
			food_upg = data.get("food_upg",1)
			dmgupgbar = data.get("dmgupgbar",0)
			foodupgbar = data.get("foodupgbar",0)
			spdupgbar = data.get("spdupgbar",0)
	else:
		save_game()
		
