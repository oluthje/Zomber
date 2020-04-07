extends StaticBody2D

var StoneParticles = preload("res://Environment/StoneMineParticles.tscn")
var StoneBreakParticles = preload("res://Environment/StoneBreakParticles.tscn")
var CarryableObject = preload("res://Environment/CarryableObject.tscn")
onready var tile_map = get_parent().get_node("TileMap")

var total_health = 100
var health = 100
var cell_index = 0
var replacement_cell_index = 1
var destroyed = false

# Carryable object
var object_name = "stone"
var object_spawn_chance = 100

func _ready():
	add_to_tilemap()
	
func add_to_tilemap():
	tile_map.set_cellv(tile_map.world_to_map(get_global_position()), cell_index)
	#get_parent().get_node("TileMap").update_pathfinding_map()
	
func remove_from_tilemap():
	tile_map.set_cellv(tile_map.world_to_map(get_global_position()), replacement_cell_index)
	get_parent().get_node("TileMap").update_pathfinding_map()

func take_damage(damage):
	health -= damage
	spawn_hit_particles()
	$BreakStage.set_frame(get_break_stage_index())
	if health <= 0 and not destroyed:
		destroyed = true
		remove_from_tilemap()
		spawn_break_particles_and_pieces()
		try_spawn_carryable_object()
		queue_free()

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
	
func try_spawn_carryable_object():
	var rand_num = rand_range(0, 100)
	if rand_num <= object_spawn_chance:
		var stone = CarryableObject.instance()
		stone.set_global_position(get_global_position())
		stone.set_up_object(object_name)
		get_parent().add_child(stone)
	
func spawn_hit_particles():
	var particles = StoneParticles.instance()
	particles.set_global_position(get_global_position())
	get_parent().add_child(particles)

func spawn_break_particles_and_pieces():
	var particles = StoneBreakParticles.instance()
	particles.set_global_position(get_global_position())
	get_parent().add_child(particles)
