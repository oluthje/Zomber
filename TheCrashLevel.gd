extends Node2D

onready var main = get_tree().get_root().get_node("Main")
var TreeNode = preload("res://Environment/Tree.tscn")
var StoneNode = preload("res://Environment/Stone.tscn")
var Boundary = preload("res://Obstacles/Boundary.tscn")

# Level settings
var map_size = Vector2(30, 20)

# Terrrain Generation
var noise

func _ready():
	$AnimationPlayer.play("fade_in")
	generate_terrain()
	spawn_world_boundaries()
	get_node("CrashSiteScript").spawn_crash_site()

func _physics_process(delta):
	main.time_played += delta
	update_player_pos_info()
	
func update_player_pos_info():
	if get_node("Player"):
		main.player_pos = get_node("Player").get_global_position()
	else:
		main.player_pos = get_node("Humvee").get_node("PlayerPos").get_global_position()
	
	var free_tiles = [main.TILES.grass, main.TILES.dirt]
	var tilemap = get_node("TileMap")
	var current_tile = tilemap.world_to_map(main.player_pos)
	if free_tiles.has(tilemap.get_cellv(current_tile)):
		main.player_tile_pos = current_tile

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
			if tile_name == main.TILES.stone and is_in_bounds(Vector2(x, y)):
				var stone = StoneNode.instance()
				stone.set_global_position(Vector2(x * 32 + 16, y * 32 + 16))
				add_child(stone)
				$TileMap.set_cellv(Vector2(x, y), get_tile_index(noise.get_noise_2d(float(x), float(y))))
			elif tile_name == main.TILES.stone and not is_in_bounds(Vector2(x, y)):
				$TileMap.set_cellv(Vector2(x, y), main.TILES.grass)
			elif tile_name != main.TILES.stone:
				$TileMap.set_cellv(Vector2(x, y), get_tile_index(noise.get_noise_2d(float(x), float(y))))
	spawn_trees()

func remove_player():
	main.player_node = get_node("Player")
	remove_child(main.player_node)

func spawn_saved_player(pos):
	main.player_node.set_global_position(pos)
	call_deferred("add_child", main.player_node)

func spawn_player(pos):
	main.player_node = main.Player.instance()
	main.player_node.set_global_position(pos)
	main.player_node.name = "Player"
	add_child(main.player_node)

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
		return main.TILES.dirt
	if noise_sample > 0.18:
		return main.TILES.stone
	return main.TILES.grass

func spawn_trees():
	for x in range(map_size.x):
		for y in range(map_size.y):
			var cell_index = $TileMap.get_cellv(Vector2(x, y))
			if cell_index == main.TILES.grass:
				if can_spawn_object_with_radius(Vector2(x, y), 2, [main.TILES.stone, main.TILES.dirt, main.TILES.tree]):
					if should_spawn_tree():
						var tree = TreeNode.instance()
						tree.set_global_position(Vector2(x * 32 + 16, y * 32 + 16))
						add_child(tree)
						$TileMap.set_cellv(Vector2(x, y), main.TILES.tree)
						
				if should_spawn_scenic_feature(Vector2(x, y)):
					randomize()
					var rand_num = rand_range(0, 3)
					$Scenery.set_cellv(Vector2(x, y), rand_num)
					
func can_spawn_object_with_radius(pos, radius, obstacles):
	var increase_radius_chance = 50
	var can_place = true
	
	randomize()
	var rand_num = rand_range(0, 100)
	if rand_num <= increase_radius_chance:
		radius += 1
	
	for x in range(radius*2):
		for y in range(radius*2):
			if obstacles.has($TileMap.get_cellv(Vector2(pos.x-radius + x, pos.y-radius + y))):
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
				
	if $TileMap.get_cellv(pos) != main.TILES.grass:
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

