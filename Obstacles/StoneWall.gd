extends StaticBody2D

var ConstructionNode = load("res://Construction/ConstructionNode.tscn")
var SmokeEffect = preload("res://Environment/SmokeEffect.tscn")
var StoneParticles = preload("res://Environment/StoneMineParticles.tscn")
var ConnectingWall = preload("res://Construction/Buildings/ConnectingWall.tscn")

onready var buildings_tile_map = get_parent().get_node("Buildings")
var cell_index = 0

var damage = 50
var health = 50
var total_health = 50

func _ready():
	set_global_position(get_snapped_pos_to_grid())
	add_to_tilemap()
	update_connecting_walls()
	update_neighbors()
	spawn_smoke_effect()

func take_damage(damage):
	health -= damage
	spawn_hit_particles()
	$AnimationPlayer.play("break" + str(get_break_stage_index()))
	if health <= 0:
		remove_from_tilemap()
		update_neighbors()
		enter_damaged_state()
		queue_free()
		
func get_snapped_pos_to_grid():
	var grid_snap_num = 16
	var pos = get_global_position()
	return Vector2(int(pos.x/grid_snap_num) * grid_snap_num, int(pos.y/grid_snap_num) * grid_snap_num)

func add_to_tilemap():
	buildings_tile_map.set_cellv(buildings_tile_map.world_to_map(get_global_position()), cell_index)
	get_parent().get_node("TileMap").update_pathfinding_map()

func remove_from_tilemap():
	buildings_tile_map.set_cellv(buildings_tile_map.world_to_map(get_global_position()), -1)
	get_parent().get_node("TileMap").update_pathfinding_map()
	
func get_break_stage_index():
	if health <= 0.20 * total_health:
		return 4
	if health <= 0.40 * total_health:
		return 3
	if health <= 0.60 * total_health:
		return 2
	if health <= 0.80 * total_health:
		return 1
	return 0

func update_connecting_walls():
	var connecting_walls = get_node("ConnectingWalls").get_children()
	if connecting_walls.size() > 0:
		for connecting_wall in connecting_walls:
			connecting_wall.queue_free()
	
	var neighbors = get_neighboring_walls()
	for neighbor in neighbors:
		spawn_connecting_wall(neighbor)

func get_neighboring_walls():
	var neighbors = []
	var tile_pos = get_parent().get_node("Buildings").world_to_map(get_global_position())
	buildings_tile_map = get_parent().get_node("Buildings")
	if buildings_tile_map.get_cellv(Vector2(tile_pos.x, tile_pos.y - 1)) == 0:
		neighbors.append("north")
	if buildings_tile_map.get_cellv(Vector2(tile_pos.x + 1, tile_pos.y)) == 0:
		neighbors.append("east")
	if buildings_tile_map.get_cellv(Vector2(tile_pos.x, tile_pos.y + 1)) == 0:
		neighbors.append("south")
	if buildings_tile_map.get_cellv(Vector2(tile_pos.x - 1, tile_pos.y)) == 0:
		neighbors.append("west")
	return neighbors

func update_neighbors():
	var positions = [Vector2(0, -32), Vector2(32, 0), Vector2(0, 32), Vector2(-32, 0)]
	var space_state = get_world_2d().direct_space_state
	var result
	for pos in positions:
		result = space_state.intersect_ray(get_global_position(), get_global_position() + pos, [self], 2)
		if result:
			if "StoneWall" in result.collider.name:
				result.collider.update_connecting_walls()
			if "ConnectingWall" in result.collider.name:
				print("detected ConnectingWall")
				result.collider.get_parent().get_parent().update_connecting_walls()

func spawn_connecting_wall(dir):
	var connecting_wall = ConnectingWall.instance()
	match dir:
		"north":
			connecting_wall.set_rotation_degrees(270)
		"east":
			pass
		"south":
			connecting_wall.set_rotation_degrees(270)
			connecting_wall.set_position(Vector2(0, 24))
		"west":
			connecting_wall.set_position(Vector2(-24, 0))
	
	get_node("ConnectingWalls").add_child(connecting_wall)

func get_rotation_to_pos(pos):
	var angle = get_angle_to(pos)
	return angle

func spawn_smoke_effect():
	for i in range(2):
		randomize()
		var rand_x = rand_range(0, 24)
		if flipped_heads():
			rand_x = -rand_x
		randomize()
		var rand_y = rand_range(0, 24)
		if flipped_heads():
			rand_y = -rand_y
		
		var smoke = SmokeEffect.instance()
		smoke.set_global_position(Vector2(get_global_position().x + rand_x, get_global_position().y + rand_y))
		get_parent().add_child(smoke)

func flipped_heads():
	randomize()
	var rand_num = rand_range(0, 100)
	if rand_num < 50:
		return true
	return false

func enter_damaged_state():
	var construction_node = ConstructionNode.instance()
	var materials = {
		Item.LOG: 0,
		Item.STONE: 1
	}
	construction_node.set_global_position(Vector2(get_global_position().x - 6, get_global_position().y - 6))
	construction_node.setup(Item.STONE_WALL, false, materials)
	get_parent().add_child(construction_node)
	queue_free()
	
func spawn_hit_particles():
	var particles = StoneParticles.instance()
	particles.set_global_position(get_global_position())
	get_parent().add_child(particles)
