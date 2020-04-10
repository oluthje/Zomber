extends Node2D

# Inventory related variables
var inventory = ["pistol", "pickaxe", "shotgun", "axe", "disabled", "disabled", "disabled", "disabled"]
var inv_ammo = [-1, -1, -1, -1, -1, -1, -1, -1] # The amount of ammo for each slot (assuming gun is in slot)

var resource_inv = ["wood", "coal", "components"]
var resource_inv_num = [0, 0, 0]

# Guns
const PISTOL = "pistol"
const SHOTGUN = "shotgun"

# Melee weapons
const AXE = "axe"
const PICKAXE = "pickaxe"

# Carryable Objects
var LOG = "log"
var STONE = "stone"

# Buildings
var WOOD_SPIKES = "wood_spikes"

# Functional keywords
const EMPTY = "empty"
const DISABLED = "disabled"
const MELEE = "melee"
const PROJECTILE = "projectile"
const ITEM = "item"

var current_inventory_slot = 0
var should_update_inventory = false	
var player_should_update_held_item = false

var item_player_can_pick_up = ""
var object_player_can_pick_up = ""

# Other Game Variables
var using_menu = false

# Loot table
onready var loot_table = {
	Item.PISTOL: 20,
	Item.AXE: 10,
	Item.SHOTGUN: 10,
	Item.PICKAXE: 10
}

var weight_sum = 0

#func _ready():
#	for i in range(100):
#		print(get_loot_drop())

func get_loot_drop():
	weight_sum = 0
	for item in loot_table:
		weight_sum += loot_table[item]

	var rand_num = rand_range(0, weight_sum)
	var current_weight = 0
	for item in loot_table:
		current_weight += loot_table[item]
		if rand_num <= current_weight:
			return item
	return "no item found"
