extends TileMap

onready var astar_node = AStar.new()
onready var map_size = get_parent().map_size
onready var map_size_offset = get_parent().map_size_offset
onready var obstacles = get_used_cells_by_id(0)
onready var _half_cell_size = cell_size / 2
var _point_path = []

# Test
var path_start_position = Vector2()
var path_end_position = Vector2()

var draw_circle_points = []
var Dot = preload("res://WhiteDot.tscn")

func _ready():
	update_pathfinding_map()

func update_pathfinding_map():
	map_size = get_parent().map_size
	map_size_offset = get_parent().map_size_offset
	astar_node.clear()
	obstacles = get_used_cells_by_id(0)
	obstacles += get_used_cells_by_id(2)
	obstacles += get_parent().get_node("Buildings").get_used_cells_by_id(0)
#	print("map_size_offset: " + str(map_size_offset) + " map_size: " + str(map_size))
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
#	draw_circle_points = walkable_cells_list
#	place_dots()
	astar_connect_walkable_cells(walkable_cells_list)
	
func place_dots():
	var children = get_children()
	if children.size() > 0:
		for child in children:
			child.queue_free()
	
	for point in draw_circle_points:
		var dot = Dot.instance()
		dot.set_global_position(point * 32 + Vector2(16, 16))
		add_child(dot)

# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles
func astar_add_walkable_cells(obstacles = []):
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(map_size_offset.x + x, map_size_offset.y + y)
			if point in obstacles:
				continue

			points_array.append(point)
			# The AStar class references points with indices
			# Using a function to calculate the index from a point's coordinates
			# ensures we always get the same index with the same input point
			var point_index = calculate_point_index(point)
			# AStar works for both 2d and 3d, so we have to convert the point
			# coordinates from and to Vector3s
			astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
	return points_array

# Once you added all points to the AStar node, you've got to connect them
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...
func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# For every cell in the map, we check the one to the top, right.
		# left and bottom of it. If it's in the map and not an obstalce,
		# We connect the current point with it
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)

			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			# Note the 3rd argument. It tells the astar_node that we want the
			# connection to be bilateral: from point A to B and B to A
			# If you set this value to false, it becomes a one-way path
			# As we loop through all points we can set it to false
			astar_node.connect_points(point_index, point_relative_index, false)


# This is a variation of the method above
# It connects cells horizontally, vertically AND diagonally
func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = calculate_point_index(point_relative)

				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node.has_point(point_relative_index):
					continue
				astar_node.connect_points(point_index, point_relative_index, true)

func is_outside_map_bounds(point):
	return point.x < map_size_offset.x or point.y < map_size_offset.y or point.x >= map_size_offset.x + map_size.x or point.y >= map_size_offset.y + map_size.y

func calculate_point_index(point):
	return point.x + map_size.x * point.y

func find_path(world_start, world_end):
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = map_to_world(Vector2(point.x, point.y)) + _half_cell_size
		path_world.append(point_world)
	return path_world

func _recalculate_path():
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	# Redraw the lines and circles from the start to the end point
#	update()
