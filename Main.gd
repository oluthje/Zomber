extends Node2D

var Game = preload("res://Game.tscn")
var MainMenu = preload("res://HUD/Menu/MainMenu.tscn")
var PauseMenu = preload("res://HUD/Menu/PauseMenu.tscn")

onready var game_node = get_game_node()

# Game development settings
var start_with_menu = false

var can_pause = false
var game_paused = false
var pause_menu_exists = false

func _ready():
	if start_with_menu:
		spawn_main_menu()
	else:
		respawn_game_node()

func _physics_process(delta):
	if Input.is_action_just_pressed("restart_game") and can_pause:
		delete_game_node()
		reset_inventory()
		respawn_game_node()
	if Input.is_action_just_pressed("pause") and can_pause:
		if not game_paused and not pause_menu_exists:
			spawn_pause_menu()
		elif pause_menu_exists:
			remove_pause_menu()

func is_within_percent_chance(percent_chance):
	randomize()
	var rand_num = rand_range(0, 100)
	if rand_num > percent_chance:
		return false
	return true

func spawn_main_menu():
	var menu = MainMenu.instance()
	add_child(menu)
	can_pause = false

func remove_main_menu():
	get_node("MainMenu").queue_free()

func spawn_pause_menu():
	pause_menu_exists = true
	game_paused = true
	get_tree().paused = true
	var menu = PauseMenu.instance()
	menu.get_node("AnimationPlayer").play("enter")
	add_child(menu)

func remove_pause_menu():
	game_paused = false
	get_tree().paused = false
	get_node("PauseMenu").get_node("AnimationPlayer").play("exit")

func reset_inventory():
	for index in Item.inventory.size():
		if Item.inventory[index] != Item.DISABLED:
			Item.inventory[index] = Item.EMPTY
	Item.inventory[0] = Item.PISTOL
	for index in Item.inv_ammo.size():
		Item.inv_ammo[index] = -1
	for index in Item.resource_inv_num.size():
		Item.resource_inv_num[index] = 0
	Item.player_health = 6

func delete_game_node():
	get_game_node().queue_free()

func get_game_node():
	for child in get_children():
		if "Game" in child.name:
			return child

func respawn_game_node():
	var game = Game.instance()
	game_node = game
	add_child(game)
	can_pause = true

func save_stats(current_stats_dict):
	var stats_dict = get_saved_stats_dict()

	for key in stats_dict:
		if key == "wave_record":
			if current_stats_dict[key] > stats_dict[key]:
				stats_dict[key] = current_stats_dict[key]
			continue
		stats_dict[key] += current_stats_dict[key]
	
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(stats_dict))
	save_game.close()

func reset_stats():
	var stats_dict = get_saved_stats_dict()

	for key in stats_dict:
		stats_dict[key] = 0
	
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(stats_dict))
	save_game.close()
	
func get_saved_stats_dict():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return

	save_game.open("user://savegame.save", File.READ)
	var current_line = parse_json(save_game.get_line())
	save_game.close()
	return current_line
	
	
	
	
