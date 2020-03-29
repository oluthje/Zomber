extends Area2D

export var pre_set_item = ""

var item_name
var ammo_count
var got_picked_up = false

func _ready():
	if pre_set_item != "":
		item_name = pre_set_item
		set_up_item(item_name)

func set_up_item(item):
	item_name = item
	
	# Guns
	if item == Item.PISTOL:
		get_node("SlotItemImage").select_item_to_display(Item.PISTOL)

	# Melee weapons
	if item == Item.AXE:
		get_node("SlotItemImage").select_item_to_display(Item.AXE)

func _on_PhysicalItem_body_entered(body):
	if "Player" in body.name:
		Item.item_player_can_pick_up = item_name
		body.pickupable_item_area = self

func _on_PhysicalItem_body_exited(body):
	if "Player" in body.name:
		Item.item_player_can_pick_up = ""
