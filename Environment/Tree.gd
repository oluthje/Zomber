extends StaticBody2D

var CarryableObject = preload("res://Environment/CarryableObject.tscn")
var TreeTrunk = preload("res://Environment/TreeLog.tscn")
var TreeChopParticles = preload("res://Environment/TreeChopParticles.tscn")
var LeafParticles = preload("res://Environment/LeafFallingParticles.tscn")
var SoundEffectPlayer = preload("res://SoundEffectPlayer.tscn")

onready var leaves_node = get_node("Leaves")

# Tree felling
var health = 30
var num_logs = 4
var log_spacing = 24

var felled = false
var angle_to_player

func _ready():
	pass

func take_damage(chopped):
	if chopped and not felled:
		$Leaves/ShakeAnimPlayer.play("bigshake")
		spawn_sound_effect_player(Item.TREE_CHOP)
		spawn_chop_particles()
		health -= 10
	elif not felled:
		$Leaves/ShakeAnimPlayer.play("smallshake")
		health -= 2.5
	if health <= 0 and not felled:
		felled = true
		angle_to_player = rad2deg(get_angle_to_player())
		$Leaves/ShakeAnimPlayer.play("finalshake")
		spawn_sound_effect_player(Item.TREE_SNAPPING)
		get_parent().current_stats_dict["trees_chopped"] += 1
		remove_from_tilemap()

func spawn_sound_effect_player(sound):
	var player = SoundEffectPlayer.instance()
	player.set_global_position(get_global_position())
	player.setup(sound, 5)
	get_parent().add_child(player)
		
func remove_from_tilemap():
	var tile_map = get_parent().get_node("TileMap")
	tile_map.set_cellv(tile_map.world_to_map(get_global_position()), 3)
	tile_map.update_pathfinding_map()

func fell_tree():
	place_logs_at_angle(angle_to_player)
	
func spawn_chop_particles():
	var chop_particles = TreeChopParticles.instance()
	chop_particles.set_global_position(get_global_position())
	chop_particles.set_rotation(get_angle_to_player())
	get_parent().add_child(chop_particles)

func spawn_leaf_particles(pos):
	var particles = LeafParticles.instance()
	particles.set_global_position(pos)
	get_parent().add_child(particles)

func get_angle_to_player():
	var game_node = get_tree().get_root().get_node("Main").game_node
	return game_node.get_rotation_to_node(get_global_position(), game_node.player_pos)

func place_logs_at_angle(degrees):
	for log_num in num_logs:
		var tree_log = CarryableObject.instance()
		var log_pos = Vector2((log_num * log_spacing) + 16, 0)
		tree_log.set_up_object(Item.LOG)
		tree_log.set_global_position(log_pos.rotated(deg2rad(degrees)) + get_global_position())
		tree_log.set_rotation(deg2rad(degrees))
		get_parent().add_child(tree_log)
		
		if log_num == num_logs - 1:
			var new_log_pos = Vector2(log_pos.x + 8, log_pos.y)
			spawn_leaf_particles(new_log_pos.rotated(deg2rad(degrees)) + get_global_position())
	queue_free()

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		$Leaves/AnimationPlayer.play("blur")
	
func _on_Area2D_body_exited(body):
	if "Player" in body.name:
		$Leaves/AnimationPlayer.play("unblur")
