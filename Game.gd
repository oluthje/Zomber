extends Node2D

var TreeNode = preload("res://Environment/Tree.tscn")
var StoneNode = preload("res://Environment/Stone.tscn")
var Boundary = preload("res://Obstacles/Boundary.tscn")

var Player = preload("res://Player/Player.tscn")

var player_pos = Vector2()
var using_menu = false

# Game settingss
var spawn_enemies = true
var map_size = Vector2(30, 20)

# Current stats
var current_stats_dict = {
	"wave_record": 0,
	"enemies_killed": 0,
	"trees_chopped": 0,
	"stone_mined": 0,
	"buildings_built": 0,
	"minutes_played:": 0
}

# Terrrain Generation
var noise
const TILES = {
	'stone': 0,
	'dirt': 1,
	'tree': 2,
	'grass': 3
}

func _ready():
	generate_terrain()
	spawn_world_boundaries()
	spawn_player()

func generate_terrain():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 15
	noise.persistence = 0.75
	noise.lacunarity = 1.75

	for x in range(map_size.x):
		for y in range(map_size.y):
			var tile_name = get_tile_index(noise.get_noise_2d(float(x), float(y)))
			if tile_name == TILES.stone and is_in_bounds(Vector2(x, y)):
				var stone = StoneNode.instance()
				stone.set_global_position(Vector2(x * 32 + 16, y * 32 + 16))
				add_child(stone)
				$TileMap.set_cellv(Vector2(x, y), get_tile_index(noise.get_noise_2d(float(x), float(y))))
			elif tile_name == TILES.stone and not is_in_bounds(Vector2(x, y)):
				$TileMap.set_cellv(Vector2(x, y), TILES.grass)
			elif tile_name != TILES.stone:
				$TileMap.set_cellv(Vector2(x, y), get_tile_index(noise.get_noise_2d(float(x), float(y))))
	spawn_trees()
	
func save_stats():
	get_parent().save_stats(current_stats_dict)
	
func spawn_player():
	var player = Player.instance()
	player.set_global_position((map_size/2) * 32)
	player.name = "Player"
	add_child(player)

func spawn_world_boundaries():
	# North
	for x in range(map_size.x):
		spawn_boundary(Vector2(x * 32 + 16, -16))
	# East
	for y in range(map_size.y):
		spawn_boundary(Vector2(map_size.x * 32 + 16, y * 32 + 16))
	# South
	for x in range(map_size.x):
		spawn_boundary(Vector2(x * 32 + 16, map_size.y * 32 + 16))	
	# West
	for y in range(map_size.y):
		spawn_boundary(Vector2(-16, y * 32 + 16))

func spawn_boundary(pos):
	var boundary = Boundary.instance()
	boundary.set_global_position(pos)
	get_node("WorldBoundaries").add_child(boundary)

func is_in_bounds(point):
	if point.x < 1 or point.y < 1 or point.x >= map_size.x - 1 or point.y >= map_size.y - 1:
		return false
	return true

func get_tile_index(noise_sample):
	if noise_sample < 0.18 and noise_sample > 0.1:
		return TILES.dirt
	if noise_sample > 0.18:
		return TILES.stone
	return TILES.grass

func spawn_trees():
	for x in range(map_size.x):
		for y in range(map_size.y):
			var cell_index = $TileMap.get_cellv(Vector2(x, y))
			if cell_index == TILES.grass:
				if can_should_spawn_tree(Vector2(x, y)):
					if should_spawn_tree():
						var tree = TreeNode.instance()
						tree.set_global_position(Vector2(x * 32 + 16, y * 32 + 16))
						add_child(tree)
						$TileMap.set_cellv(Vector2(x, y), TILES.tree)
						
				if should_spawn_scenic_feature(Vector2(x, y)):
					randomize()
					var rand_num = rand_range(0, 3)
					$Scenery.set_cellv(Vector2(x, y), rand_num)

func can_should_spawn_tree(pos):
	var tree_radius = 2
	var increase_radius_chance = 50
	var can_place = true
	
	randomize()
	var rand_num = rand_range(0, 100)
	if rand_num <= increase_radius_chance:
		tree_radius += 1
	
	for x in range(tree_radius*2):
		for y in range(tree_radius*2):
			if $TileMap.get_cellv(Vector2(pos.x-tree_radius + x, pos.y-tree_radius + y)) != TILES.grass: #and is_in_bounds(Vector2(x, y)):
				can_place = false
	
	if can_place:
		return true
	return false
	
func should_spawn_scenic_feature(pos):
	var radius = 2
	var increase_radius_chance = 75
	var can_place = true
	
	randomize()
	var rand_num = rand_range(0, 100)
	if rand_num <= increase_radius_chance:
		radius += 1
	
	for x in range(radius*2):
		for y in range(radius*2):
			if $Scenery.get_cellv(Vector2(pos.x-radius + x, pos.y-radius + y)) != -1 and is_in_bounds(Vector2(x, y)):
				can_place = false
				
	if $TileMap.get_cellv(pos) != TILES.grass:
		can_place = false
	
	if can_place:
		return true
	return false

func should_spawn_tree():
	var spawn_chance = 50
	randomize()
	var rand_num = rand_range(0, 100)
	if rand_num <= spawn_chance:
		return true
	return false

# Handy methods
func get_rotation_to_node(start_pos, end_pos):
	var angle = start_pos.angle_to_point(end_pos)
	return angle
	

