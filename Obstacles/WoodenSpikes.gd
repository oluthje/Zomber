extends StaticBody2D

var ConstructionNode = load("res://Construction/ConstructionNode.tscn")
var ConstructedParticles = preload("res://Construction/ConstructedParticles.tscn")

var damage = 50
var health = 5

func _ready():
	spawn_constructed_particles()

func take_damage():
	health -= 1
	if health <= 0:
		enter_damaged_state()
		queue_free()
		
func spawn_constructed_particles():
	var particles = ConstructedParticles.instance()
	particles.set_global_position(get_global_position())
	get_parent().add_child(particles)

func enter_damaged_state():
	var construction_node = ConstructionNode.instance()
	construction_node.set_global_position(Vector2(get_global_position().x - 8, get_global_position().y - 8))
	construction_node.setup(Item.WOOD_SPIKES, false)
	get_parent().add_child(construction_node)
	queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		take_damage()
