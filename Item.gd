extends Node2D

# Inventory related variables
var inventory = ["pistol", "ak47", "axe", "empty", "disabled", "disabled", "disabled", "disabled"]
var inv_ammo = [-1, -1, -1, -1, -1, -1, -1, -1] # The amount of ammo for each slot (assuming gun is in slot)
var player_health = 6
var update_player_health = false

var resource_inv = ["wood", "coal", "components"]
var resource_inv_num = [0, 0, 0]

# Guns
const PISTOL = "pistol"
const SHOTGUN = "shotgun"
const AK47 = "ak47"

# Melee weapons
const AXE = "axe"
const PICKAXE = "pickaxe"

# Carryable Objects
var LOG = "log"
var STONE = "stone"
var COMPONENT = "component"

# Buildings
var WOOD_SPIKES = "wood_spikes"
var TURRET = "turret"
var STONE_WALL = "stone_wall"

# Enemies
var ZOMBIE = "zombie"
var FAST_ZOMBIE = "fast_zombie"
var RIOT_SHIELD_ZOMBIE = "riot_shield_zombie"
var ARMORED_ZOMBIE_BOSS = "armored_zombie_boss"

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
var wave_num = 0

# Loot tables
onready var tier1_loot_table = {
	Item.PISTOL: 1,
	Item.AXE: 10,
	Item.PICKAXE: 10,
	Item.COMPONENT: 2
}

onready var tier2_loot_table = {
	Item.SHOTGUN: 10,
	Item.AK47: 5,
	Item.AXE: 1,
	Item.PICKAXE: 1,
	Item.COMPONENT: 3
}

onready var tier3_loot_table = {
	Item.SHOTGUN: 8,
	Item.AK47: 10,
	Item.AXE: 2,
	Item.PICKAXE: 2,
	Item.COMPONENT: 4
}

var weight_sum = 0

func get_loot_drop(tier):
	var loot_table
	match tier:
		1:
			loot_table = tier1_loot_table
		2:
			loot_table = tier2_loot_table
		3:
			loot_table = tier3_loot_table
	
	weight_sum = 0
	for item in loot_table:
		weight_sum += loot_table[item]
	
	randomize()
	var rand_num = rand_range(0, weight_sum)
	var current_weight = 0
	for item in loot_table:
		current_weight += loot_table[item]
		if rand_num <= current_weight:
			return item
	return "no item found"
