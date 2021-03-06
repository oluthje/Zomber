extends Node2D

var EnemySpawnPoint = preload("res://Enemies/EnemySpawnPoint.tscn")
onready var main = get_tree().get_root().get_node("Main")
onready var road_path_matrix
onready var road_connections_matrix
onready var road_chunk_size
onready var current_chunks

var Zombie = preload("res://Enemies/Zombie/Zombie.tscn")
var FastZombie = preload("res://Enemies/FastZombie/FastZombie.tscn")
var RiotZombie = preload("res://Enemies/RiotSheildZombie/RiotShieldZombie.tscn")

func update_spawn_points_queue():
	get_node("Timer").set_wait_time(0.05)
	get_node("Timer").start()
	
func spawn_zombie():
	var zombie = Zombie.instance()
	zombie.set_global_position(get_rand_spawn_point_pos())
	get_parent().get_node("Enemies").add_child(zombie)

func get_rand_spawn_point_pos():
	randomize()
	var spawn_points = get_node("SpawnPoints").get_children()
	var rand_index = rand_range(0, spawn_points.size() - 1)
	
	return spawn_points[rand_index].get_global_position()

func update_spawn_points():
	road_path_matrix = get_parent().get_node("RoadLayoutScript").road_matrix
	road_connections_matrix = get_parent().get_node("RoadLayoutScript").road_connections_matrix
	road_chunk_size = get_parent().road_chunk_size
	current_chunks = get_parent().current_chunks
	
	var child_spawn_points = get_node("SpawnPoints").get_children()
	if child_spawn_points.size() > 0:
		for child in child_spawn_points:
			child.queue_free()
	
	for current_chunk in current_chunks:
		var connection_points = road_connections_matrix[current_chunk.x][current_chunk.y]
		for connection_point in connection_points:
			if not connection_point_connects_to_loaded_chunk(current_chunk, connection_point):
				place_spawn_points_along_connection_point(connection_point, current_chunk)
	var chunk_connection_points = []

func connection_point_connects_to_loaded_chunk(chunk_pos, connection_point):
	if current_chunks.has(chunk_pos + connection_point):
		return true
	return false

func place_spawn_points_along_connection_point(connection_point, chunk_pos):
	var spawn_points = []
	var rot
	for x in range(road_chunk_size/32):
		spawn_points.append(Vector2(x, 0))
		
	match connection_point:
		Vector2(0, -1):
			rot = 0
		Vector2(1, 0):
			rot = 90
		Vector2(0, 1):
			rot = 180
		Vector2(-1, 0):
			rot = 270
	
	spawn_points = get_rotated_points(rot, spawn_points)
	var chunk_pos_offset = (chunk_pos * road_chunk_size)/32
	for spawn_point in spawn_points:
		var pos = (chunk_pos_offset + spawn_point) * 32
		place_enemy_spawn_point(pos, rot)
	
func get_rotated_points(degrees, points):
	var rotated_points = []
	match degrees:
		90:
			for point in points:
				rotated_points.append(Vector2(abs(point.y - road_chunk_size/32), point.x))
		180:
			for point in points:
				rotated_points.append(Vector2(abs(point.x - road_chunk_size/32), abs(point.y - road_chunk_size/32)))
		270:
			for point in points:
				rotated_points.append(Vector2(point.y, abs(point.x - road_chunk_size/32)))
		_:
			rotated_points = points
	return rotated_points

func place_enemy_spawn_point(pos, rot):
	var offset_pos = Vector2()
	match rot:
		90:
			offset_pos = Vector2(-32, 0)
		180:
			offset_pos = Vector2(-32, -32)
		270:
			offset_pos = Vector2(0, -32)
		
	var tile_pos = get_parent().get_node("TileMap").world_to_map(pos)
	if get_parent().get_node("TileMap").get_cellv(tile_pos) == main.TILES.stone:
		return
		
	var point = EnemySpawnPoint.instance()
	point.set_global_position(Vector2(pos.x + 16, pos.y + 16) + offset_pos)
	get_node("SpawnPoints").add_child(point)

func _on_Timer_timeout():
	update_spawn_points()
	get_parent().get_node("TileMap").update_pathfinding_map()

func _on_SpawnZombieTimer_timeout():
	if main.spawn_enemies:
		spawn_zombie()
