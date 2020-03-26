extends Node2D

var Zombie = preload("res://Enemies/Zombie.tscn")
var PanningLabel = preload("res://HUD/Labels/NewWaveLabel.tscn")

onready var rest_timer = get_node("RestTimer")
onready var spawn_timer = get_node("SpawnTimer")

# Wave variables
var wave_num = 0
var wave_time = 12
var wave_rest_time = 1
var can_advance_to_next_wave = true

# Spawning variables
var num_zombies = 3
var zombies_left = 3
var spawn_time = 0
	
func _physics_process(delta):
	var zombies_alive = get_tree().get_nodes_in_group("enemies").size()
	if zombies_alive <= 0 and can_advance_to_next_wave:
		rest_timer.set_wait_time(wave_rest_time)
		rest_timer.start()
		can_advance_to_next_wave = false
#
#	zombies_alive = get_tree().get_nodes_in_group("enemies").size()
#	var label = get_node("Label")
#	label.set_text(str(zombies_alive))

func next_wave():
	wave_num += 1
	num_zombies += 1
	zombies_left = num_zombies
	
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

func spawn_zombie():
	var zombie = Zombie.instance()
	zombie.set_global_position(get_rand_spawner_pos())
	get_parent().add_child(zombie)

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
		spawn_zombie()
		spawn_timer.start()
	else:
		can_advance_to_next_wave = true

func _on_RestTimer_timeout():
	next_wave()
