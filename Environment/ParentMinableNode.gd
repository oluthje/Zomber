extends StaticBody2D

var StoneParticles = preload("res://Environment/StoneMineParticles.tscn")
var StoneBreakParticles = preload("res://Environment/StoneBreakParticles.tscn")
var CarryableObject = preload("res://Environment/CarryableObject.tscn")
onready var tile_map = get_parent().get_node("TileMap")
onready var main = get_tree().get_root().get_node("Main")

var SoundEffectPlayer = preload("res://SoundEffectPlayer.tscn")

var total_health = 100
var health = 100
var cell_index = 0
var replacement_cell_index = 1
var destroyed = false

# Carryable object
var object_name = "stone"
var object_spawn_chance = 100

func _ready():
	total_health = health
	add_to_tilemap()

func add_to_tilemap():
	if main.current_level == main.levels.THE_ROAD:
		pass
	else:
		tile_map.set_cellv(tile_map.world_to_map(get_global_position()), cell_index)
	#get_parent().get_node("TileMap").update_pathfinding_map()
	
func remove_from_tilemap():
	if main.current_level == main.levels.THE_ROAD:
		pass
	else:
		tile_map.set_cellv(tile_map.world_to_map(get_global_position()), replacement_cell_index)
		get_parent().get_node("TileMap").update_pathfinding_map()

func take_damage(damage):
	health -= damage
	spawn_hit_particles()
	$BreakStage.set_frame(get_break_stage_index())
	if health <= 0 and not destroyed:
		if object_name == "stone":
			get_parent().current_stats_dict["stone_mined"] += 1
		destroyed = true
		spawn_sound_effect_player(Item.STONE_BREAK)
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
	
func spawn_sound_effect_player(sound):
	var player = SoundEffectPlayer.instance()
	player.set_global_position(get_global_position())
	player.setup(sound, 5)
	get_parent().add_child(player)

func try_spawn_carryable_object():
	var num_stones = 1
	if get_tree().get_root().get_node("Main").is_within_percent_chance(13):
		num_stones += 1
	
	for num in range(num_stones):
		var stone = CarryableObject.instance()
		stone.set_global_position(get_global_position())
		stone.set_up_object(object_name, true)
		get_parent().add_child(stone)
	
func spawn_hit_particles():
	var particles = StoneParticles.instance()
	particles.set_global_position(get_global_position())
	get_parent().add_child(particles)

func spawn_break_particles_and_pieces():
	var particles = StoneBreakParticles.instance()
	particles.set_global_position(get_global_position())
	get_parent().add_child(particles)
