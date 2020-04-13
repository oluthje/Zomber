extends Node2D

# Enemies
var Zombie = preload("res://Enemies/Zombie/Zombie.tscn")
var FastZombie = preload("res://Enemies/FastZombie/FastZombie.tscn")
var RiotZombie = preload("res://Enemies/RiotSheildZombie/RiotShieldZombie.tscn")

# Bosses
var ArmoredZombie = preload("res://Enemies/Bosses/ArmoredZombieBoss.tscn")

var PanningLabel = preload("res://HUD/Labels/NewWaveLabel.tscn")

onready var rest_timer = get_node("RestTimer")
onready var spawn_timer = get_node("SpawnTimer")

# Wave variables
var wave_num = 0
var wave_time = 12
var wave_rest_time = 0#5
var can_advance_to_next_wave = true

# Spawning variables
var num_zombies = 3
var num_bosses = 1
var bosses_left = 1
var zombies_left = 3
var spawn_time = 0
var additional_zombies_per_round = 3

# Loot table
onready var spawn_table = {
	Item.ZOMBIE: 23,
	Item.RIOT_SHIELD_ZOMBIE: 10,
	Item.FAST_ZOMBIE: 10
}

var weight_sum = 0

func get_enemy_by_weight():
	weight_sum = 0
	for enemy in spawn_table:
		weight_sum += spawn_table[enemy]
	
	randomize()
	var rand_num = rand_range(0, weight_sum)
	var current_weight = 0
	for enemy in spawn_table:
		current_weight += spawn_table[enemy]
		if rand_num <= current_weight:
			return enemy
	return "no item found"

func _physics_process(delta):
	var zombies_alive = get_tree().get_nodes_in_group("enemies").size()
	if zombies_alive <= 0 and can_advance_to_next_wave:
		rest_timer.set_wait_time(wave_rest_time)
		rest_timer.start()
		can_advance_to_next_wave = false

func next_wave():
	if get_parent().spawn_enemies:
		wave_num += 1
		num_zombies += additional_zombies_per_round
		zombies_left = num_zombies
		bosses_left = num_bosses
		
		set_wave_label_text()
		spawn_panning_wave_label()
		
		var spawn_time = float(wave_time)/float(num_zombies)
		spawn_timer.set_wait_time(spawn_time)
		spawn_timer.start()

func spawn_panning_wave_label():
	var wave_label = PanningLabel.instance()
	wave_label.set_text("Wave " + str(wave_num))
	get_parent().get_node("CanvasLayer").add_child(wave_label)

func set_wave_label_text():
	get_parent().get_node("CanvasLayer").get_node("WaveCountLabel").set_text(str(wave_num))

func spawn_enemy():
	var enemy_name = get_enemy_by_weight()
	var enemy
	
	match enemy_name:
		Item.ZOMBIE:
			enemy = Zombie.instance()
		Item.FAST_ZOMBIE:
			enemy = FastZombie.instance()
		Item.RIOT_SHIELD_ZOMBIE:
			enemy = RiotZombie.instance()
	
	enemy.set_global_position(get_rand_spawner_pos())
	get_parent().add_child(enemy)

func randomly_spawn_boss():
	var percent_chance = 35
	randomize()
	var rand_num = rand_range(0, 100)
	if rand_num <= percent_chance and wave_num > 3:
		var armored_zombie = ArmoredZombie.instance()
		armored_zombie.set_global_position(get_rand_spawner_pos())
		get_parent().add_child(armored_zombie)

func get_rand_spawner_pos():
	var spawners = []
	for child in get_node("Spawnpoints").get_children():
		if "Spawnpoint" in child.name:
			spawners.append(child)

	randomize()
	var rand_num = rand_range(0, spawners.size())
	return spawners[rand_num].get_global_position()

func _on_SpawnTimer_timeout():
	if zombies_left > 0:
		zombies_left -= 1
		spawn_enemy()
		spawn_timer.start()
	elif bosses_left > 0:
		bosses_left -= 1
		randomly_spawn_boss()
		spawn_timer.start()
	else:
		can_advance_to_next_wave = true

func _on_RestTimer_timeout():
	next_wave()
