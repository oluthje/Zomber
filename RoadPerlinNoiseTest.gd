extends Node2D

# Rect drawing
var rect_size = 6
var map_size = Vector2(32, 32)
var outline_thickness = 1.0

# Road terrain
var noise
var addition = 0.2
var noise_values_matrix = []
var modified_points_matrix = []
var straight_road_points = [Vector2(0, map_size.y/2), Vector2(map_size.x - 1, map_size.y/2)]
var curved_road_points = [Vector2(0, map_size.y/2), Vector2(map_size.x/2, map_size.y/2), Vector2(map_size.x/2, map_size.y - 1)]
var interp_road_points = []
var road_size = 6
var road_to_terrain_transition_size = 12

var stand_alone = true
func _ready():
	if stand_alone:
		setup_noise_values_matrix()
		setup_modified_points_matrix()
#		generate_terrain_at_chunk_pos(Vector2(0, 0))
		for x in range(map_size.x):
			for y in range(map_size.y):
				noise_values_matrix[x][y] = 1
		generate_road(straight_road_points, 180)

func get_stone_positions_from_noise(chunk_pos, curved_road, road_rotation):
	setup_noise_values_matrix()
	setup_modified_points_matrix()
	generate_terrain_at_chunk_pos(chunk_pos)
	if curved_road:
		generate_road(curved_road_points, road_rotation)
	else:
		generate_road(straight_road_points, road_rotation)
		
	var stone_positions = []
	for x in range(map_size.x):
		for y in range(map_size.y):
			if noise_values_matrix[x][y] > 0.07:
				stone_positions.append(Vector2(x * 32, y * 32) + Vector2(16, 16))
	return stone_positions
			
func _draw():
	if stand_alone:
		for x in range(map_size.x):
			for y in range(map_size.y):
				var color_num = noise_values_matrix[x][y]
				color_num += addition
				# Filled rect
				draw_rect(Rect2(x * rect_size, y * rect_size, rect_size, rect_size), Color(color_num, color_num, color_num), true, 1.0)
	
				# Outline rect
				if interp_road_points.has(Vector2(x, y)):
					draw_rect(Rect2(x * rect_size, y * rect_size, rect_size, rect_size), Color(0.5, 0, 0), false, 2)

func generate_terrain_at_chunk_pos(chunk_pos):
	randomize()
	noise = OpenSimplexNoise.new()
	if stand_alone:
		noise.seed = 3#get_parent().terrain_seed
	else:
		noise.seed = 3#get_parent().terrain_seed
	noise.octaves = 2.5#4
	noise.period = 22.0
	noise.persistence = 0.8
	
	var pos_offset
	if stand_alone:
		pos_offset = Vector2(0, 0)
	else:
		pos_offset = Vector2(get_parent().road_chunk_size/32 * chunk_pos.x, get_parent().road_chunk_size/32 * chunk_pos.y)
	for x in range(map_size.x):
		for y in range(map_size.y):
			noise_values_matrix[x][y] = noise.get_noise_2d(float(pos_offset.x + x), float(pos_offset.y + y))

func generate_road(road_points, rot):
	interp_road_points = get_all_points_between_points(road_points)
	interp_road_points = get_rotated_points(rot, interp_road_points)
	for x in range(map_size.x):
		for y in range(map_size.x):
			if interp_road_points.has(Vector2(x, y)):
				noise_values_matrix[x][y] = -0.5
				roadify_area_around_point(Vector2(x, y))
	create_road_to_terrain_transition()

func roadify_area_around_point(point):
	for x in range(road_size):
		for y in range(road_size):
			var new_point = point + Vector2(x, y) - Vector2(road_size/2, road_size/2)
			if is_in_bounds(Vector2(new_point.x, new_point.y)):
				noise_values_matrix[new_point.x][new_point.y] = -0.5
				#modified_points_matrix[new_point.x][new_point.y] = true

func create_road_to_terrain_transition():
	for x in range(map_size.x):
		for y in range(map_size.y):
			var point = Vector2(x, y)
			if interp_road_points.has(point):
				smoothen_area_around_point(point)
				pass

func smoothen_area_around_point(point):
	for x in range(road_to_terrain_transition_size):
		for y in range(road_to_terrain_transition_size):
			var new_point = point + Vector2(x, y) - Vector2(road_to_terrain_transition_size/2, road_to_terrain_transition_size/2)
			if is_in_bounds(Vector2(new_point.x, new_point.y)) and modified_points_matrix[new_point.x][new_point.y] == false:
				var new_color_num = get_reduced_height_from_distance_to_center(new_point)
				print("new_color_num: " + str(new_color_num))
				#var reduction = noise_values_matrix[new_point.x][new_point.y] * percent_reduction * 2
				noise_values_matrix[new_point.x][new_point.y] = new_color_num
				modified_points_matrix[new_point.x][new_point.y] = true

func get_reduced_height_from_distance_to_center(point):
	var total_distance = (road_size/2) + road_to_terrain_transition_size
	var center_point = Vector2()
	for interp_point in interp_road_points:
		if point.x == interp_point.x or point.y == interp_point.y:
			center_point = interp_point
	
	var difference = point - center_point
	print("point: " + str(point) + " center_point: " + str(center_point) + " difference: " + str(difference))
	var reduction = 0
	difference = Vector2(abs(difference.x), abs(difference.y))
	if difference.x == 0:
		var center_point_color_num = noise_values_matrix[center_point.x][center_point.y]
		var max_distance_color_num = noise_values_matrix[point.x][total_distance]
		var point_color_num = noise_values_matrix[point.x][point.y]
		reduction = lerp(center_point_color_num, max_distance_color_num, point_color_num)
	elif difference.y == 0:
		var center_point_color_num = noise_values_matrix[center_point.x][center_point.y]
		var max_distance_color_num = noise_values_matrix[total_distance][point.y]
		var point_color_num = noise_values_matrix[point.x][point.y]
		reduction = lerp(center_point.x, total_distance, point.x)
	return reduction

func is_in_bounds(pos):
	if pos.x < 0 or pos.y < 0 or pos.x >= map_size.x or pos.y >= map_size.y:
		return false
	return true

func get_rotated_points(degrees, points):
	var rotated_points = []
	match degrees:
		90:
			for point in points:
				rotated_points.append(Vector2(abs(point.y - map_size.y), point.x))
		180:
			for point in points:
				rotated_points.append(Vector2(abs(point.x - map_size.x), abs(point.y - map_size.y)))
		270:
			for point in points:
				rotated_points.append(Vector2(point.y, abs(point.x - map_size.x)))
		_:
			rotated_points = points
	return rotated_points
	
func get_all_points_between_points(points):
	var interpolated_points = []
	var first_point = true
	var last_point = Vector2()
	for point in points:
		if first_point:
			first_point = false
			last_point = point
			continue
		
		var x_dif = point.x - last_point.x
		var y_dif = point.y - last_point.y
		if x_dif > 0:
			interpolated_points.append(last_point)
			for x in range(x_dif):
				interpolated_points.append(Vector2(last_point.x + x, last_point.y))
		elif y_dif > 0:
			for y in range(y_dif):
				interpolated_points.append(Vector2(last_point.x, last_point.y + y))
		
		last_point = point
	interpolated_points.append(last_point)
	return interpolated_points

func setup_noise_values_matrix():
	for x in range(map_size.x):
		noise_values_matrix.append([])
		noise_values_matrix[x]=[]
		for y in range(map_size.y):
			noise_values_matrix[x].append([])
			noise_values_matrix[x][y]
	
func setup_modified_points_matrix():
	for x in range(map_size.x):
		modified_points_matrix.append([])
		modified_points_matrix[x]=[]
		for y in range(map_size.y):
			modified_points_matrix[x].append([])
			modified_points_matrix[x][y] = false
	
