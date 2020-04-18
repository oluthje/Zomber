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
var wave_rest_time = 0
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

func _ready():
#	wave_num = 5
	num_zombies = wavenum_to_zombienum(wave_num)
	place_spawners()
	
func _physics_process(delta):
	var zombies_alive = get_tree().get_nodes_in_group("enemies").size()
	if zombies_alive <= 0 and can_advance_to_next_wave:
		rest_timer.set_wait_time(wave_rest_time)
		rest_timer.start()
		can_advance_to_next_wave = false
	set_wave_label_text()

func wavenum_to_zombienum(wavenum):
	return wavenum * 3 + 3

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

func next_wave():
	if get_parent().spawn_enemies:
		wave_num += 1
		Item.wave_num = wave_num
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
	var rest_timer_time = $RestTimer.get_time_left()
	var spawn_timer_time = $SpawnTimer.get_time_left()
	get_parent().get_node("CanvasLayer").get_node("WaveCountLabel").set_text(str(wave_num)) #+ " rest timer: " + str(rest_timer_time) + " spawn timer: " + str(spawn_timer_time) + " zombies left: " + str(zombies_left))

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
	
	if zombies_left == 1:
		enemy.spawn_loot_on_death = true
	
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
	
func place_spawners():
	var map_size = get_parent().map_size
	var margin = 250
	
	# North
	for x in range(map_size.x):
		spawn_spawn_pos(Vector2(x * 32 + 16, -margin))
	# East
	for y in range(map_size.y):
		spawn_spawn_pos(Vector2(map_size.x * 32 + margin, y * 32 + 16))
	# South
	for x in range(map_size.x):
		spawn_spawn_pos(Vector2(x * 32 + 16, map_size.y * 32 + margin))
	# West
	for y in range(map_size.y):
		spawn_spawn_pos(Vector2(-16, y * 32 + margin))

func spawn_spawn_pos(pos):
	var spawn_pos = Node2D.new()
	spawn_pos.set_global_position(pos)
	get_node("Spawnpoints").add_child(spawn_pos)

func get_rand_spawner_pos():
	var spawners = []
	for child in get_node("Spawnpoints").get_children():
		#if "Spawnpoint" in child.name:
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
