extends Node2D

onready var main = get_tree().get_root().get_node("Main")
onready var game = get_parent()
onready var map_size = get_parent().map_size
var Humvee = preload("res://Environment/Humvee.tscn")

var pos_increments = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
var crashsite_search_matrix = []

func spawn_crash_site():
	var pos = Vector2(map_size/2)
	var spawn_range = 5
	var cell_index
	var spawned_humvee = false
	
	setup_2d_array()
	spiral_search_for_free_tiles()

func spiral_search_for_free_tiles():
	var found_crashsite = false
	crashsite_search_matrix[map_size.x/2][map_size.y/2] = Vector2(map_size/2)
	
	while not found_crashsite:
		for x in range(map_size.x):
			for y in range(map_size.y):
				if crashsite_search_matrix[x][y]:
					if get_parent().can_spawn_object_with_radius(Vector2(x, y), 2, [main.TILES.stone]):
						spawn_humvee(Vector2(x, y) * 32)
						return
					try_expand_point(Vector2(x, y))

func try_expand_point(tile_pos):
	var tile
	for increment in pos_increments:
		tile = tile_pos + increment
		if tile.x < map_size.x and tile.y < map_size.y and tile.x > 0 and tile.y > 0:
			if not crashsite_search_matrix[tile.x][tile.y]:
				crashsite_search_matrix[tile.x][tile.y] = tile

func spawn_humvee(pos):
	var humvee = Humvee.instance()
	humvee.set_global_position(pos)
	get_parent().add_child(humvee)
	
	game.spawn_player(Vector2(pos.x, pos.y + 32))

func setup_2d_array():
	for x in range(game.map_size.x):
		crashsite_search_matrix.append([])
		crashsite_search_matrix[x]=[]
		for y in range(game.map_size.y):
			crashsite_search_matrix[x].append([])
			crashsite_search_matrix[x][y]
