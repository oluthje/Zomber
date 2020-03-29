extends Node2D

# Inventory related variables
var inventory = ["pistol", "pistol", "axe", "disabled", "disabled", "disabled", "disabled", "disabled"]
var inv_ammo = [-1, -1, -1, -1, -1, -1, -1, -1] # The amount of ammo for each slot (assuming gun is in slot)

var resource_inv = ["wood", "coal", "components"]
var resource_inv_num = [0, 0, 0]

# Guns
const PISTOL = "pistol"
const SHOTGUN = "shotgun"

# Melee weapons
const AXE = "axe"

# Carryable Objects
var LOG = "log"

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
