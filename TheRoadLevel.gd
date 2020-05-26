extends Node2D

var TreeNode = preload("res://Environment/Tree.tscn")
var StoneNode = preload("res://Environment/Stone.tscn")
var Boundary = preload("res://Obstacles/Boundary.tscn")

var RoadChunk = preload("res://Environment/Road/RoadChunk.tscn")
var CurvedRoadChunk = preload("res://Environment/Road/CurvedRoadChunk.tscn")

# Game settings  CODE TO BE PUT UNDER Main node
var spawn_enemies = false
var map_size = Vector2(4, 6)
var time_played = 0
var Player = preload("res://Player/Player.tscn")
var player_pos = Vector2()
var player_tile_pos = Vector2()
var player_node
var using_menu = false
const TILES = {
	'stone': 0,
	'dirt': 1,
	'tree': 2,
	'grass': 3
}

onready var road_path_matrix = get_node("RoadLayoutScript").road_matrix
onready var road_connections_matrix = get_node("RoadLayoutScript").road_connections_matrix
var road_path_poses_used = []
var road_chunks = []

func _ready():
	for y in range(map_size.y * ((12*128)/32)):
		for x in range(map_size.x * ((12*128)/32)):
			$TileMap.set_cellv(Vector2(x, y), TILES.grass)
	get_node("Camera2D").increment = 100000000#12 * 128
	setup_road_chunks_matrix()
	place_roads()
	spawn_player(Vector2(200, 200))

func _physics_process(delta):
	time_played += delta
	update_player_pos_info()
	
func place_roads():
	for y in range(map_size.y):
		for x in range(map_size.x):
			if ["x", "s", "e"].has(road_path_matrix[x][y]):
				var connection_points = road_connections_matrix[x][y]
				if connection_points.size() > 0:
					derive_road_type_from_points(connection_points, Vector2(x, y))

func derive_road_type_from_points(points, pos):
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
	
	place_road_chunk(pos, curved, rot)

func are_arrays_equal(arr1, arr2):
	var are_equal = true
	for element in arr1:
		if not arr2.has(element):
			are_equal = false
	return are_equal
	
func place_road_chunk(chunk_pos, curved, rot):
	var road
	if curved:
		road = CurvedRoadChunk.instance()
	else:
		road = RoadChunk.instance()
	road.set_global_position(chunk_pos * 12 * 128)
	road.set_road_rotation(rot)
	road.chunk_pos = chunk_pos
	road_chunks[chunk_pos.x][chunk_pos.y] = road
	get_node("RoadChunks").call_deferred("add_child", road)
	
func update_player_pos_info():
	if get_node("Player"):
		player_pos = get_node("Player").get_global_position()
	else:
		player_pos = get_node("Humvee").get_node("PlayerPos").get_global_position()
	
	var free_tiles = [TILES.grass, TILES.dirt]
	var tilemap = get_node("TileMap")
	var current_tile = tilemap.world_to_map(player_pos)
	if free_tiles.has(tilemap.get_cellv(current_tile)):
		player_tile_pos = current_tile

func remove_player():
	player_node = get_node("Player")
	remove_child(player_node)

func spawn_saved_player(pos):
	player_node.set_global_position(pos)
	call_deferred("add_child", player_node)

func spawn_player(pos):
	player_node = Player.instance()
	player_node.set_global_position(pos)
	player_node.name = "Player"
	add_child(player_node)

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

func setup_road_chunks_matrix():
	for x in range(map_size.x):
		road_chunks.append([])
		road_chunks[x]=[]
		for y in range(map_size.y):
			road_chunks[x].append([])
			road_chunks[x][y]
