extends Node2D

const dirs = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
onready var map_size = get_parent().map_size
var road_matrix = []

func _ready():
	setup_road_matrix()
	generate_road_path()
	print_road_matrix()

func generate_road_path():
	randomize()
	var rand_x = int(rand_range(0, map_size.x - 1))
	var current_pos = Vector2(rand_x, 0)
	road_matrix[current_pos.x][current_pos.y] = "s"
	while true:
		current_pos = get_next_path_dir(current_pos) + current_pos
		if road_matrix[current_pos.x][current_pos.y] != "s":
			road_matrix[current_pos.x][current_pos.y] = "x"
		if current_pos.y == map_size.y - 1:
			road_matrix[current_pos.x][current_pos.y] = "e"
			break

func get_next_path_dir(pos):
	var possible_dirs = []
	var usable_dirs = []
	for dir in dirs:
		possible_dirs.append(dir)
	for dir in possible_dirs:
		if is_in_bounds(pos + dir) and road_matrix[pos.x + dir.x][pos.y + dir.y] != "x":
			usable_dirs.append(dir)
	var rand_index = get_rand_array_index(usable_dirs.size())
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

func print_road_matrix():
	var some_string = ""
	for y in range(map_size.y):
		some_string = ""
		for x in range(map_size.x):
			some_string += road_matrix[x][y] + " "
		print(some_string)
