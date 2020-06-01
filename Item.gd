extends Node2D

# Inventory related variables
var inventory = ["pistol", "pickaxe", "mp5", "kar98k", "disabled", "disabled", "disabled", "disabled"]
var inv_ammo = [-1, -1, -1, -1, -1, -1, -1, -1] # The amount of ammo for each slot (assuming gun is in slot)
var player_health = 6
var update_player_health = false

var resource_inv = ["wood", "coal", "components"]
var resource_inv_num = [0, 0, 0]

# Guns
const PISTOL = "pistol"
const SHOTGUN = "shotgun"
const AK47 = "ak47"
const MP5 = "mp5"
const KAR98K = "kar98k"

# Melee weapons
const AXE = "axe"
const PICKAXE = "pickaxe"

# Carryable Objects
var LOG = "log"
var STONE = "stone"
var COMPONENT = "component"
# Humvee parts
const ENGINE = "engine"
const SPARK_PLUG = "spark_plug"
const FUEL = "fuel"
const REPAIR_KIT = "repair_kit"

# Items
const STIM_SHOT = "stim_shot"

# Buildings
var WOOD_SPIKES = "wood_spikes"
var TURRET = "turret"
var STONE_WALL = "stone_wall"

# Enemies
var ZOMBIE = "zombie"
var FAST_ZOMBIE = "fast_zombie"
var RIOT_SHIELD_ZOMBIE = "riot_shield_zombie"
var ARMORED_ZOMBIE_BOSS = "armored_zombie_boss"

# Sounds
const TREE_CHOP = "tree_chop"
const TREE_SNAPPING = "tree_snapping"
const TREE_HIT_GROUND = "tree_hit_ground"
const GRASS_FOOT_STEP = "grass_foot_step"
const STONE_BREAK = "stone_break"
const STONE_HIT = "stone_hit"
const MELEE_SWOOSH = "melee_swoosh"
const PLAYER_DAMAGE = "player_damage"
const CORPSE_FALL = "corpse_fall"
const ZOMBIE_SOUND = "zombie_sound"
# Guns
const PISTOL_SHOT = "pistol_shot"
const PISTOL_COCKING = "pistol_cocking"
const PISTOL_LOAD = "pistol_load"
const SHOTGUN_SHOT = "shotgun_shot"
const SHOTGUN_LOAD = "shotgun_load"
const AK47_SHOT = "ak47_shot"
const TURRET_SHOT = "turret_shot"
const KAR98K_SHOT = "kar98k_shot"
const KAR98K_COCKBACK = "kar98k_cockback"
const KAR98K_COCKFORWARD = "kar98k_cockforward"
const KAR98K_CLIPFEED = "kar98k_clipfeed"
# Building
const BUILD_COMPLETE = "build_complete"
const ADDED_RESOURCE = "added_resource"

# Particles
const HUMVEE_SMOKE_PARTICLES = "humvee_smoke_particles"

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
onready var items_loot_table = {
	Item.COMPONENT: 1,
	Item.ENGINE: 1,
	Item.SPARK_PLUG: 1,
	Item.FUEL: 1,
	Item.REPAIR_KIT: 1,
}

onready var max_droppings = {
	Item.AXE: 1,
	Item.PICKAXE: 1,
	Item.ENGINE: 1,
	Item.SPARK_PLUG: 1,
	Item.FUEL: 1,
	Item.REPAIR_KIT: 1,
}

# Loot tables
onready var tier1_loot_table = {
	Item.AXE: 5,
	Item.PICKAXE: 5,
	Item.PISTOL: 3,
	Item.SHOTGUN: 8,
	Item.MP5: 5
}

onready var tier2_loot_table = {
	Item.AXE: 5,
	Item.PICKAXE: 5,
	Item.SHOTGUN: 10,
	Item.AK47: 5,
	Item.KAR98K: 5
}

onready var tier3_loot_table = {
	Item.AK47: 10,
	Item.KAR98K: 8,
	Item.MP5: 2
}

var weight_sum = 0

func get_loot_drop(tier):
	var dropped_item = false
	while not dropped_item:
		var loot_table
		match tier:
			0:
				loot_table = items_loot_table
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
				if not should_remove_from_loot_table(item):
					return item
				continue
		return "no item found"

func should_remove_from_loot_table(drop):
	if max_droppings.has(drop):
		if max_droppings[drop] > 0:
			max_droppings[drop] -= 1
			return false
		if max_droppings[drop] == 0:
			remove_drop_from_loot_table(drop)
			return false
	return false
	
func remove_drop_from_loot_table(drop):
	var loot_tables = [tier3_loot_table, tier3_loot_table, tier3_loot_table]
	for loot_table in loot_tables:
		for key in loot_table:
			if key == drop:
				tier1_loot_table.erase(key)
