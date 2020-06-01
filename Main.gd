extends Node2D

onready var level_node = get_level_node()
var TheCrash = preload("res://TheCrashLevel.tscn")
var TheRoad = preload("res://TheRoadLevel.tscn")
var TheBunker = preload("res://TheRoadLevel.tscn")
var MainMenu = preload("res://HUD/Menu/MainMenu.tscn")
var PauseMenu = preload("res://HUD/Menu/PauseMenu.tscn")
var SoundEffectPlayer = preload("res://SoundEffectPlayer.tscn")

var Player = preload("res://Player/Player.tscn")
var player_pos = Vector2()
var player_tile_pos = Vector2()
var player_node

var using_menu = false
var time_played = 0
const TILES = {
	'stone': 0,
	'dirt': 1,
	'tree': 2,
	'grass': 3
}

var can_pause = false
var game_paused = false
var pause_menu_exists = false
var current_stats_dict = {
	"wave_record": 0,
	"enemies_killed": 0,
	"trees_chopped": 0,
	"stone_mined": 0,
	"buildings_built": 0,
	"minutes_played:": 0
}
enum levels {THE_CRASH, THE_ROAD, THE_BUNKER}
var current_level = levels.THE_ROAD#CRASH

# Game development settings
var start_with_menu = false
var spawn_enemies = false

func _ready():
	if start_with_menu:
		spawn_main_menu()
	else:
		respawn_level()

func _physics_process(delta):
	if Input.is_action_just_pressed("restart_game") and can_pause:
		delete_game_node()
		reset_inventory()
		respawn_level()
	if Input.is_action_just_pressed("pause") and can_pause:
		if not game_paused and not pause_menu_exists:
			spawn_pause_menu()
		elif pause_menu_exists:
			remove_pause_menu()

func delete_game_node():
	get_level_node().queue_free()

func get_level_node():
	for child in get_children():
		if "Level" in child.name:
			return child

func respawn_level():
	var level
	match current_level:
		levels.THE_CRASH:
			level = TheCrash.instance()
		levels.THE_ROAD:
			level = TheRoad.instance()
		levels.THE_BUNKER:
			level = TheBunker.instance()
	level_node = level
	add_child(level)
	can_pause = true

# HANDY METHODS =====================================
func spawn_sound_effect_player(sound):
	var player = SoundEffectPlayer.instance()
	player.set_global_position(get_global_position())
	player.setup(sound, 5)
	get_parent().add_child(player)
func get_rotation_to_node(start_pos, end_pos):
	var angle = start_pos.angle_to_point(end_pos)
	return angle
func get_rounded_pos(pos):
	var new_pos = Vector2(round(pos.x), round(pos.y))
	return new_pos
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
	
	
	
	
