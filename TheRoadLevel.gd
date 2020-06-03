extends Node2D

onready var main = get_tree().get_root().get_node("Main")
var TreeNode = preload("res://Environment/Tree.tscn")
var StoneNode = preload("res://Environment/Stone.tscn")
var Boundary = preload("res://Obstacles/Boundary.tscn")
var RoadChunk = preload("res://Environment/Road/RoadChunk.tscn")
var CurvedRoadChunk = preload("res://Environment/Road/CurvedRoadChunk.tscn")

# Level settings
var road_map_size = Vector2(2, 6)
var map_size = Vector2(32, 64)
var map_size_offset = Vector2(0, 0)

# Road placement
onready var road_path_matrix = get_node("RoadLayoutScript").road_matrix
onready var road_connections_matrix = get_node("RoadLayoutScript").road_connections_matrix
var road_path_poses_used = []
var road_chunks = []
var road_chunk_size = 8 * 128
var start_pos = Vector2()

# Chunk loading/unloading
onready var terrain_seed = randi()
var chunk_removed = Vector2()
var current_chunks = []
var player_chunk = Vector2(0, 1000)
var saved_chunks = []
var saved_chunk_dict = {
	"chunk_pos": 0,
	"connection_points": [],
	"saved_objects_dict": {}
}
var saved_objects_dict = {
	"stone_positions": [],
	"tree_positions": []
}

func _ready():
	get_node("Camera2D").increment = 10000000
	setup_road_chunks_matrix()
	setup_start_position()

func _physics_process(delta):
	main.time_played += delta
	update_player_pos_info()
	load_unload_chunks()

	get_node("CanvasLayer/Label").set_text("chunks: " + str(get_node("RoadChunks").get_child_count()))
	
func update_map_size_and_offset():
	var chunk_a_to_b_connection_point = current_chunks[1] - current_chunks[0]
	chunk_a_to_b_connection_point = Vector2(abs(chunk_a_to_b_connection_point.x), abs(chunk_a_to_b_connection_point.y))
	if chunk_a_to_b_connection_point == Vector2(1, 0):
		map_size = Vector2(64, 32)
	else:
		map_size = Vector2(32, 64)
	var start_offset_chunk
	var chunk_a = current_chunks[0]
	var chunk_b = current_chunks[1]
	if chunk_a.x < chunk_b.x or chunk_a.y < chunk_b.y:
		start_offset_chunk = chunk_a
	else:
		start_offset_chunk = chunk_b
	
	map_size_offset = start_offset_chunk * 32

func load_unload_chunks():
	if player_chunk != get_player_chunk() or not are_arrays_equal(current_chunks, [get_player_chunk(), get_closest_chunk_to_player(get_two_nearby_road_chunks())]):
		player_chunk = get_player_chunk()
		current_chunks.clear()
		current_chunks.append(player_chunk)
		current_chunks.append(get_closest_chunk_to_player(get_two_nearby_road_chunks()))
		
		for chunk_pos in current_chunks:
			if ["x", "s", "e"].has(road_path_matrix[chunk_pos.x][chunk_pos.y]) and not saved_chunk_exists(chunk_pos) and not chunk_is_in_tree(chunk_pos):
				var connection_points = road_connections_matrix[chunk_pos.x][chunk_pos.y]
				if connection_points.size() > 0:
					save_chunk_data(chunk_pos, connection_points, [])
					setup_road_chunk(connection_points, chunk_pos, [])
			elif saved_chunk_exists(chunk_pos) and not chunk_is_in_tree(chunk_pos):
				var loaded_chunk = get_saved_chunk(chunk_pos)
				setup_road_chunk(loaded_chunk["connection_points"], loaded_chunk["chunk_pos"], loaded_chunk["saved_objects_dict"]["stone_positions"])
				
		if get_node("RoadChunks").get_children().size() > 0:
			for road_chunk in get_node("RoadChunks").get_children():
				if not current_chunks.has(road_chunk.chunk_pos):
					chunk_removed = road_chunk.chunk_pos
					edit_chunk_data(road_chunk.chunk_pos, "stone_positions", road_chunk.stone_positions)
					road_chunk.queue_free()
		
		update_tilemap()
		update_map_size_and_offset()
		spawn_chunk_boundaries()
		get_node("Camera2D").set_limits()
		get_node("TileMap").update_pathfinding_map()
		get_node("EnemySpawnSystem").update_spawn_points_queue()
		
func update_tilemap():
	if not current_chunks.has(chunk_removed):
		var chunk_tile_pos = (chunk_removed * road_chunk_size)/32
		for y in range((road_chunk_size)/32):
			for x in range((road_chunk_size)/32):
				$TileMap.set_cellv(Vector2(chunk_tile_pos.x + x, chunk_tile_pos.y + y), -1)
	
	for chunk_pos in current_chunks:
		var chunk_tile_pos = (chunk_pos * road_chunk_size)/32
		for y in range((road_chunk_size)/32):
			for x in range((road_chunk_size)/32):
				if $TileMap.get_cellv(Vector2(chunk_tile_pos.x + x, chunk_tile_pos.y + y)) != main.TILES.stone:
					$TileMap.set_cellv(Vector2(chunk_tile_pos.x + x, chunk_tile_pos.y + y), main.TILES.grass)
					
func get_chunk_node(chunk_pos):
	for chunk_node in get_node("RoadChunks").get_children():
		if chunk_node.chunk_pos == chunk_pos:
			return chunk_node

func chunk_is_in_tree(chunk_pos):
	var chunks_in_tree = get_node("RoadChunks").get_children()
	for chunk in chunks_in_tree:
		if chunk.chunk_pos == chunk_pos:
			return true
	return false

func save_chunk_data(chunk_pos, connection_points, stone_positions):
	var saved_chunk_dict_instance = {
		"chunk_pos": 0,
		"connection_points": [],
		"saved_objects_dict": {}
	}
	var saved_objects_dict_instance = {
		"stone_positions": [],
		"tree_positions": []
	}
	saved_objects_dict_instance["stone_positions"] = stone_positions
	
	saved_chunk_dict_instance["chunk_pos"] = chunk_pos
	saved_chunk_dict_instance["connection_points"] = connection_points
	saved_chunk_dict_instance["saved_objects_dict"] = saved_objects_dict_instance
	saved_chunks.append(saved_chunk_dict_instance)
	
func get_saved_chunk(chunk_pos):
	for chunk in saved_chunks:
		for key in saved_chunk_dict:
			if key == "chunk_pos" and chunk[key] == chunk_pos:
				return chunk
	
func saved_chunk_exists(chunk_pos):
	for chunk in saved_chunks:
		for key in saved_chunk_dict:
			if key == "chunk_pos" and chunk[key] == chunk_pos:
				return true
	return false
	
func edit_chunk_data(chunk_pos, key, new_value):
	var chunk_for_edit_index
	var index = 0
	for chunk in saved_chunks:
		for key in saved_chunk_dict:
			if key == "chunk_pos" and chunk[key] == chunk_pos:
				chunk_for_edit_index = index
		index += 1
	if key == "stone_positions":
		saved_chunks[chunk_for_edit_index]["saved_objects_dict"]["stone_positions"] = new_value

func get_current_chunks():
	var chunks = []
	var player_chunk = main.player_pos/road_chunk_size
	return player_chunk
	
func get_two_nearby_road_chunks():
	var chunks = []
	var increments = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	for increment in increments:
		var incre_chunk = player_chunk + increment
		if get_node("RoadLayoutScript").is_in_bounds(incre_chunk):
			if road_connections_matrix[incre_chunk.x][incre_chunk.y].has(-increment):
				chunks.append(incre_chunk)
				
	return chunks

func get_closest_chunk_to_player(chunk_poses):
	var distances = []
	var closest_chunk_index = 0
	for chunk_pos in chunk_poses:
		var chunk_center = (chunk_pos * road_chunk_size) + Vector2(road_chunk_size/2, road_chunk_size/2)
		var distance_to_player = main.player_pos.distance_to(chunk_center)
		distances.append(distance_to_player)
	if distances.size() == 0:
		return Vector2(0, 0)
	elif distances.size() == 1:
		return chunk_poses[0]
	elif distances.size() == 2:
		if distances[0] > distances[1]:
			return chunk_poses[1]
		return chunk_poses[0]

func get_player_chunk():
	var player_chunk = main.player_pos/road_chunk_size
	player_chunk = Vector2(int(player_chunk.x), int(player_chunk.y))
	return player_chunk
	
func update_player_pos_info():
	if main.player_node.is_inside_tree():
		main.player_pos = get_node("Player").get_global_position()
	else:
		main.player_pos = get_node("Humvee").get_node("PlayerPos").get_global_position()
	
	var free_tiles = [main.TILES.grass, main.TILES.dirt]
	var tilemap = get_node("TileMap")
	var current_tile = tilemap.world_to_map(main.player_pos)
	if free_tiles.has(tilemap.get_cellv(current_tile)):
		main.player_tile_pos = current_tile

func setup_start_position():
	for y in range(road_map_size.y):
		for x in range(road_map_size.x):
			if "s" == (road_path_matrix[x][y]):
				var num = road_chunk_size + (road_chunk_size)/2
				start_pos = Vector2(x, y) * num
				
	spawn_player(Vector2(start_pos.x + (road_chunk_size/2), start_pos.y + 32))
	get_node("Humvee").set_global_position(Vector2(start_pos.x + (road_chunk_size/2) + 128, start_pos.y + 32))

func setup_road_chunk(points, pos, stone_positions):
	var curved = false
	var rot = 0
	
	if are_arrays_equal(points, [Vector2(0, -1), Vector2(0, 1)]):
		rot = 90
		curved = false
	elif are_arrays_equal(points, [Vector2(-1, 0), Vector2(0, 1)]):
		rot = 0
		curved = true
	elif are_arrays_equal(points, [Vector2(-1, 0), Vector2(0, -1)]):
		rot = 90
		curved = true
	elif are_arrays_equal(points, [Vector2(1, 0), Vector2(0, -1)]):
		rot = 180
		curved = true
	elif are_arrays_equal(points, [Vector2(1, 0), Vector2(0, 1)]):
		rot = 270
		curved = true
	
	place_road_chunk(pos, curved, rot, stone_positions)
	
func place_road_chunk(chunk_pos, curved, rot, stone_positions):
	var road
	if curved:
		road = CurvedRoadChunk.instance()
	else:
		road = RoadChunk.instance()
	road.set_global_position(chunk_pos * road_chunk_size)
	road.set_road_rotation(rot)
	road.chunk_pos = chunk_pos
	road.stone_positions = stone_positions
	road_chunks[chunk_pos.x][chunk_pos.y] = road
	get_node("RoadChunks").call_deferred("add_child", road)

func are_arrays_equal(arr1, arr2):
	var are_equal = true
	for element in arr1:
		if not arr2.has(element):
			are_equal = false
	return are_equal

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

func spawn_chunk_boundaries():
	var boundaries = get_node("WorldBoundaries").get_children()
	if boundaries.size() > 0:
		for child in boundaries:
			child.queue_free()
	
	var offset = map_size_offset * 32
	# North
	for x in range(map_size.x):
		spawn_boundary(Vector2(x * 32 + 16, -16) + offset)
	# East
	for y in range(map_size.y):
		spawn_boundary(Vector2(map_size.x * 32 + 16, y * 32 + 16) + offset)
	# South
	for x in range(map_size.x):
		spawn_boundary(Vector2(x * 32 + 16, map_size.y * 32 + 16) + offset)
	# West
	for y in range(map_size.y):
		spawn_boundary(Vector2(-16, y * 32 + 16) + offset)

func spawn_boundary(pos):
	var boundary = Boundary.instance()
	boundary.set_global_position(pos)
	get_node("WorldBoundaries").add_child(boundary)

func is_in_bounds(point):
	if point.x < 1 or point.y < 1 or point.x >= road_map_size.x - 1 or point.y >= road_map_size.y - 1:
		return false
	return true

func setup_road_chunks_matrix():
	for x in range(road_map_size.x):
		road_chunks.append([])
		road_chunks[x]=[]
		for y in range(road_map_size.y):
			road_chunks[x].append([])
			road_chunks[x][y]
