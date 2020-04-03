extends Node2D

onready var label = get_node("Label")

func _physics_process(delta):
	var text = ""
	if Item.inv_ammo[Item.current_inventory_slot] != -1:
		text = str(Item.inv_ammo[Item.current_inventory_slot])
	label.set_text(text)
