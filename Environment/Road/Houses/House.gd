extends Node2D

var CarryableObject = preload("res://Environment/CarryableObject.tscn")
var locked = false
var spawn_gatekey = false
var spawn_key = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		
func spawn_loot():
	get_node("Door").set_locked(locked)
	if spawn_key:
		spawn_key(Item.KEY)
	elif spawn_gatekey:
		spawn_key(Item.GATEKEY)

func spawn_key(key_type):
	print("spawned: " + str(key_type))
	randomize()
	var spawn_points = get_node("LootSpawnPoints").get_children()
	var rand_num = int(rand_range(0, spawn_points.size()))
	
	var object = CarryableObject.instance()
	object.set_up_object(key_type, false)
	add_child(object)
	object.set_global_position(spawn_points[rand_num].get_global_position())
	spawn_points[rand_num].queue_free()
