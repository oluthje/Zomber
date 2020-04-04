extends StaticBody2D

var CarryableObject = preload("res://Environment/CarryableObject.tscn")
var TreeTrunk = preload("res://Environment/TreeLog.tscn")
var TreeChopParticles = preload("res://Environment/TreeChopParticles.tscn")

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
		spawn_chop_particles()
		health -= 10
	elif not felled:
		$Leaves/ShakeAnimPlayer.play("smallshake")
		health -= 2.5
	if health <= 0 and not felled:
		felled = true
		angle_to_player = rad2deg(get_angle_to_player())
		$Leaves/ShakeAnimPlayer.play("finalshake")

func fell_tree():
	place_logs_at_angle(angle_to_player)
	
func spawn_chop_particles():
	var chop_particles = TreeChopParticles.instance()
	chop_particles.set_global_position(get_global_position())
	chop_particles.set_rotation(get_angle_to_player())
	get_parent().add_child(chop_particles)

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
	queue_free()

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		$Leaves/AnimationPlayer.play("blur")
	
func _on_Area2D_body_exited(body):
	if "Player" in body.name:
		$Leaves/AnimationPlayer.play("unblur")
