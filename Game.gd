extends Node2D

var TreeNode = preload("res://Environment/Tree.tscn")
var StoneNode = preload("res://Environment/Stone.tscn")

var player_pos = Vector2()
var using_menu = false

# Game settings
var spawn_enemies = true
var map_size = Vector2(36, 18)

# Terrrain Generation
var noise
const TILES = {
	'stone': 0,
	'dirt': 1,
	'tree': 2,
	'grass': 3
}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	#generate_terrain()

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
			if tile_name == TILES.stone:
				var stone = StoneNode.instance()
				stone.set_global_position(Vector2(x * 32 + 16, y * 32 + 16))
				add_child(stone)
			$TileMap.set_cellv(Vector2(x, y), get_tile_index(noise.get_noise_2d(float(x), float(y))))
		
	spawn_trees()

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
			if $TileMap.get_cellv(Vector2(pos.x-tree_radius + x, pos.y-tree_radius + y)) != TILES.grass:
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
			if $Scenery.get_cellv(Vector2(pos.x-radius + x, pos.y-radius + y)) != -1:
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
	

