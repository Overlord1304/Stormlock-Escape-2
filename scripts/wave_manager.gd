extends Node

@export var enemy_scene: PackedScene
@export var enemies_per_wave := 5
@export var time_between_waves := 3.0

var current_wave := 0
var enemies_alive := 0

var available_spawns: Array = []

@onready var wave_label := get_parent().get_node("ui/WaveLabel")
@onready var spawn_points := get_tree().get_nodes_in_group("spawn point")

func _ready():
	await get_tree().create_timer(3).timeout
	start_next_wave()

func start_next_wave():
	current_wave += 1
	wave_label.text = "Wave " + str(current_wave)

	enemies_alive = enemies_per_wave + current_wave * 2

	
	available_spawns = spawn_points.duplicate()

	for i in enemies_alive:
		if available_spawns.is_empty():
			break 
		spawn_enemy()

func spawn_enemy():
	var spawn = available_spawns.pick_random()
	available_spawns.erase(spawn)

	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn.global_position
	get_parent().add_child(enemy)

	enemy.died.connect(_on_enemy_died)

func _on_enemy_died():
	enemies_alive -= 1

	if enemies_alive <= 0:
		for storm in get_tree().get_nodes_in_group("storm"):
			storm.reset_storm()
		await get_tree().create_timer(time_between_waves).timeout
		start_next_wave()
