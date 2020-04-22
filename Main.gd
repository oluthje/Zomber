extends Node2D

var Game = preload("res://Game.tscn")
var MainMenu = preload("res://HUD/Menu/MainMenu.tscn")
var PauseMenu = preload("res://HUD/Menu/PauseMenu.tscn")

onready var game_node = get_game_node()

var start_with_menu = true

var can_pause = false
var game_paused = false
var pause_menu_exists = false

func _ready():
	#save_stats()
	load_stats()
	if start_with_menu:
		spawn_main_menu()

func _physics_process(delta):
	if Input.is_action_just_pressed("restart_game") and can_pause:
		delete_game_node()
		reset_inventory()
		respawn_game_node()
	if Input.is_action_just_pressed("pause") and can_pause:
		if not game_paused and not pause_menu_exists:
			spawn_pause_menu()
		else:
			remove_pause_menu()

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
	pause_menu_exists = false
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
	
func save_stats():
	var stats_dict = {
		"wave_record": 0,
		"enemies_killed": 0,
		"trees_chopped": 0
	}
	stats_dict["wave_record"] = 5
	
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(stats_dict))
	save_game.close()

func load_stats():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	save_game.open("user://savegame.save", File.READ)
	var current_line = parse_json(save_game.get_line())
	#print("tried load: " + str(current_line))
	print("wave_record: " + str(current_line["wave_record"]))
#	while not save_game.eof_reached():
#		var current_line = parse_json(save_game.get_line())
#		print(current_line)
#        # Firstly, we need to create the object and add it to the tree and set its position.
#        var new_object = load(current_line["filename"]).instance()
#        get_node(current_line["parent"]).add_child(new_object)
#        new_object.position = Vector2(current_line["pos_x"], current_line["pos_y"])
#        # Now we set the remaining variables.
#        for i in current_line.keys():
#            if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
#                continue
#            new_object.set(i, current_line[i])
	save_game.close()
