extends "res://Environment/ParentMinableNode.gd"

func _ready():
	health = 100
	cell_index = 0
	
	# Carryable object
	object_name = Item.STONE
	object_spawn_chance = 35
	._ready()
