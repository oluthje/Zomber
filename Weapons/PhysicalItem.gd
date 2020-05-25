extends Area2D

export var pre_set_item = ""
export var pre_set_ammo = 0

var item_name
var ammo_count
var got_picked_up = false

func _ready():
	if pre_set_item != "":
		item_name = pre_set_item
		set_up_item(item_name, pre_set_ammo)

func set_up_item(item, ammo_num):
	ammo_count = ammo_num
	item_name = item
	#print("item: " + str(item))
	get_node("SlotItemImage").select_item_to_display(item)

func _on_PhysicalItem_body_entered(body):
	if "Player" in body.name:
		Item.item_player_can_pick_up = item_name
		body.pickupable_item_area = self

func _on_PhysicalItem_body_exited(body):
	if "Player" in body.name:
		Item.item_player_can_pick_up = ""
