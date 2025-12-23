extends Node

@export var enemy_scenes = [
	{"ps": preload("res://scenes/purpleslime.tscn")},
	{"pss": preload("res://scenes/purpleslimesmall.tscn")},
	{"c": preload("res://scenes/crab.tscn")},
	{"cs": preload("res://scenes/crabsmall.tscn")},
	{"m": preload("res://scenes/mech.tscn")}
]
@export var food_scene: PackedScene
@export var boss_scenes = [
	{"psb": preload("res://scenes/purpleslimeboss.tscn")},
	{"cb": preload("res://scenes/crabboss.tscn")},
	{"mb": preload("res://scenes/mb.tscn")}
]
@export var enemies_per_wave := 7
@export var time_between_waves := 3.0
@export var food_per_wave = 3
var current_wave := 14
var enemies_alive

var available_spawns: Array = []
var spawned_food: Array = []
@onready var wave_label := get_parent().get_node("ui/WaveLabel")
@onready var spawn_points := get_tree().get_nodes_in_group("spawn point")

func _ready():
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
	current_wave += 1
	wave_label.text = "Wave " + str(current_wave)
	enemies_alive = enemies_per_wave
	available_spawns = spawn_points.duplicate()
	spawn_food()
	if current_wave % 5 == 0:
		spawn_boss()
	else:
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
func _on_enemy_died():
	enemies_alive -= 1

	if enemies_alive <= 0:
		despawn_food()
		for storm in get_tree().get_nodes_in_group("storm"):
			storm.reset_storm()
		await get_tree().create_timer(time_between_waves).timeout
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
	await get_tree().create_timer(time_between_waves).timeout
	start_next_wave()
