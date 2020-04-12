extends Node2D

var Game = preload("res://Game.tscn")
onready var game_node = get_game_node()

func _physics_process(delta):
	if Input.is_action_just_pressed("restart_game"):
		delete_game_node()
		reset_inventory()
		respawn_game_node()

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
		
