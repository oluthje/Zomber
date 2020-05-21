extends Node2D

var LootCrate = preload("res://Loot/Crate.tscn")

onready var map_size = get_parent().get_parent().map_size
onready var player_tile_pos = get_parent().get_parent().player_tile_pos
onready var game = get_parent().get_parent()
var cell_index
var spawn_loot_crate = false
var pos_increments = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
var search_matrix = []

func find_loot_crate_spawn():
	player_tile_pos = get_parent().get_parent().player_tile_pos
	setup_2d_array()
	block_nearby_player_position(player_tile_pos)
	spiral_search_for_free_tiles()

func spiral_search_for_free_tiles():
	var found_crashsite = false
	search_matrix[player_tile_pos.x][player_tile_pos.y] = Vector2(player_tile_pos)
	
	while not found_crashsite:
		for x in range(map_size.x):
			for y in range(map_size.y):
				if search_matrix[x][y]:
					if game.can_spawn_object_with_radius(Vector2(x, y), 1, [game.TILES.stone]) and player_tile_pos != Vector2(x, y):
						spawn_loot_crate(Vector2(x, y) * 32)
						return
					try_expand_point(Vector2(x, y))
					
func block_nearby_player_position(tile_pos):
	var tile
	for increment in pos_increments:
		tile = tile_pos + increment
		if tile.x < map_size.x and tile.y < map_size.y and tile.x > 0 and tile.y > 0:
			search_matrix[tile.x][tile.y] = Vector2(tile.x, tile.y)
	
func try_expand_point(tile_pos):
	var tile
	for increment in pos_increments:
		tile = tile_pos + increment
		if tile.x < map_size.x and tile.y < map_size.y and tile.x > 0 and tile.y > 0:
			if not search_matrix[tile.x][tile.y]:
				search_matrix[tile.x][tile.y] = tile

func spawn_loot_crate(pos):
	var loot_crate = LootCrate.instance()
	loot_crate.set_global_position(pos)
	get_parent().get_parent().add_child(loot_crate)

func setup_2d_array():
	for x in range(game.map_size.x):
		search_matrix.append([])
		search_matrix[x]=[]
		for y in range(game.map_size.y):
			search_matrix[x].append([])
			search_matrix[x][y]
