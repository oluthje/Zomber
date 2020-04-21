extends StaticBody2D

var ConstructionNode = load("res://Construction/ConstructionNode.tscn")
var SmokeEffect = preload("res://Environment/SmokeEffect.tscn")

var damage = 50
var health = 5

func _ready():
	spawn_smoke_effect()

func take_damage():
	health -= 1
	if health <= 0:
		#enter_damaged_state()
		queue_free()

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
	construction_node.set_global_position(Vector2(get_global_position().x - 8, get_global_position().y - 8))
	construction_node.setup(Item.WOOD_SPIKES, false, null)
	get_parent().add_child(construction_node)
	queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage, get_rotation_to_pos(body.get_global_position()))
		take_damage()
