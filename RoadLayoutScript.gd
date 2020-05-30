extends Node2D

const dirs = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
onready var map_size = get_parent().map_size
var road_matrix = []
var road_connections_matrix = []
var last_pos = Vector2(0, 0)
var new_path_dir = Vector2()

func _ready():
	setup_road_matrix()
	setup_road_connections_matrix()
	generate_road_path()

func generate_road_path():
	randomize()
	var rand_x = int(rand_range(0, map_size.x - 1))
	var current_pos = Vector2(rand_x, 0)
	road_matrix[current_pos.x][current_pos.y] = "s"
	road_connections_matrix[current_pos.x][current_pos.y].append(Vector2(0, -1))
	last_pos = current_pos
	while true:
		current_pos = get_next_path_dir(current_pos) + current_pos
		if road_matrix[current_pos.x][current_pos.y] != "s":
			road_matrix[current_pos.x][current_pos.y] = "x"
			road_connections_matrix[current_pos.x][current_pos.y].append(-new_path_dir)
			road_connections_matrix[last_pos.x][last_pos.y].append(new_path_dir)
		if current_pos.y == map_size.y - 1:
			road_matrix[current_pos.x][current_pos.y] = "e"
			break
		last_pos = current_pos

func get_next_path_dir(pos):
	var possible_dirs = []
	var usable_dirs = []
	for dir in dirs:
		possible_dirs.append(dir)
	for dir in possible_dirs:
		if is_in_bounds(pos + dir) and not ["x", "s", "e"].has(road_matrix[pos.x + dir.x][pos.y + dir.y]):
			usable_dirs.append(dir)
	var rand_index = get_rand_array_index(usable_dirs.size())
	new_path_dir = usable_dirs[rand_index]
	return usable_dirs[rand_index]
	
func get_rand_array_index(size):
	randomize()
	return int(rand_range(0, size))
	
func is_in_bounds(pos):
	if pos.x < 0 or pos.y < 0 or pos.x >= map_size.x or pos.y >= map_size.y:
		return false
	return true

func setup_road_matrix():
	for x in range(map_size.x):
		road_matrix.append([])
		road_matrix[x]=[]
		for y in range(map_size.y):
			road_matrix[x].append([])
			road_matrix[x][y] = "-"
			
func setup_road_connections_matrix():
	for x in range(map_size.x):
		road_connections_matrix.append([])
		road_connections_matrix[x]=[]
		for y in range(map_size.y):
			road_connections_matrix[x].append([])
			road_connections_matrix[x][y] = []

func print_road_matrix():
	var some_string = ""
	for y in range(map_size.y):
		some_string = ""
		for x in range(map_size.x):
			some_string += road_matrix[x][y] + " "
		print(some_string)
