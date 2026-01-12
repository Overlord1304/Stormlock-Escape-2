extends Node

@export var enemy_scenes = [
	{"ps": preload("res://scenes/purpleslime.tscn")},
	{"pss": preload("res://scenes/purpleslimesmall.tscn")},
	{"c": preload("res://scenes/crab.tscn")},
	{"cs": preload("res://scenes/crabsmall.tscn")},
	{"m": preload("res://scenes/mech.tscn")}
]
@export var food_scene: PackedScene
@export var lightning_scene: PackedScene
@export var boss_scenes = [
	{"psb": preload("res://scenes/purpleslimeboss.tscn")},
	{"cb": preload("res://scenes/crabboss.tscn")},
	{"mb": preload("res://scenes/mb.tscn")}
]
@export var enemies_per_wave := 7
@export var food_per_wave = 3
var current_wave := 0
var enemies_alive
var lightning_spawned = false
var last_wave_was_boss = false
var available_spawns: Array = []
var spawned_food: Array = []
@onready var wave_label := get_parent().get_node("ui/WaveLabel")
@onready var spawn_points := get_tree().get_nodes_in_group("spawn point")

func _ready():
	$"../bgm".play()
	await get_tree().create_timer(3).timeout
	start_next_wave()
func get_random_enemy():
	var rand = randi() % 100
	if current_wave < 5:
		if rand < 60:
			return enemy_scenes[0]["ps"]
		else:
			return enemy_scenes[1]["pss"]
	elif current_wave < 10:
		if rand < 50:
			return enemy_scenes[2]["c"]
		elif rand > 50 and rand < 80:
			return enemy_scenes[0]["ps"]
		else:
			return enemy_scenes[3]["cs"]
	elif current_wave > 10:
		if rand < 50:
			return enemy_scenes[4]["m"]
		else:
			return enemy_scenes[3]["cs"] 
func get_random_boss():
	if current_wave == 5:
		return boss_scenes[0]["psb"]
	elif current_wave == 10:
		return boss_scenes[1]["cb"]
	elif current_wave >= 15:
		return boss_scenes[2]["mb"]
func start_next_wave():
	lightning_spawned = false
	current_wave += 1
	wave_label.text = "Wave " + str(current_wave)
	enemies_alive = enemies_per_wave
	available_spawns = spawn_points.duplicate()
	spawn_food()
	spawn_lightning()
	var is_boss_wave = current_wave % 5 == 0
	if is_boss_wave and not last_wave_was_boss:
		switch_music($"../bgm",$"../bmp",0.5)
	elif not is_boss_wave and last_wave_was_boss:
		switch_music($"../bmp",$"../bgm",0.5)
	last_wave_was_boss = is_boss_wave
	if is_boss_wave:
		enemies_alive = 1
		spawn_boss()
	else:
		enemies_alive = enemies_per_wave
		for i in enemies_alive:
			if available_spawns.is_empty():
				break 
			spawn_enemy()
func spawn_food():
	for i in food_per_wave:
		if available_spawns.is_empty():
			break
		var spawn = available_spawns.pick_random()
		available_spawns.erase(spawn)
		var food = food_scene.instantiate()
		food.global_position = spawn.global_position
		get_parent().add_child(food)
		spawned_food.append((food))

func spawn_enemy():
	if available_spawns.is_empty():
		return
	var spawn = available_spawns.pick_random()
	available_spawns.erase(spawn)

	var enemy = get_random_enemy().instantiate()
	enemy.global_position = spawn.global_position
	get_parent().add_child(enemy)

	enemy.died.connect(_on_enemy_died)
func spawn_boss():
	if available_spawns.is_empty():
		return
	var spawn = available_spawns.pick_random()
	available_spawns.erase(spawn)
	var boss = get_random_boss().instantiate()
	boss.global_position = spawn.global_position
	get_parent().add_child(boss)
	boss.died.connect(_on_boss_died)
func spawn_lightning():
	if lightning_spawned:
		return
	if available_spawns.is_empty():
		return
	var spawn = available_spawns.pick_random()
	available_spawns.erase(spawn)
	var lightning = lightning_scene.instantiate()
	lightning.global_position = spawn.global_position
	get_parent().add_child(lightning)
	lightning_spawned = true
func _on_enemy_died():
	enemies_alive -= 1

	if enemies_alive <= 0:
		despawn_food()
		for storm in get_tree().get_nodes_in_group("storm"):
			storm.reset_storm()
		
		start_next_wave()

func despawn_food():
	for food in spawned_food:
		if is_instance_valid(food):
			food.queue_free()
	spawned_food.clear()
func _on_boss_died():
	despawn_food()
	for storm in get_tree().get_nodes_in_group("storm"):
		storm.reset_storm()
	start_next_wave()

func switch_music(from_player: AudioStreamPlayer, to_player: AudioStreamPlayer, duration: float):
	if from_player == to_player:
		return
	var tween = get_tree().create_tween()
	tween.tween_property(from_player, "volume_db", -80, duration)
	tween.tween_callback(func ():
		from_player.stop()
	)
	tween.tween_callback(func ():
		to_player.volume_db = -80
		to_player.play()
	)
	tween.tween_property(to_player, "volume_db", -19, duration)
