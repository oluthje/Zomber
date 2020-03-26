extends Node2D

onready var label = get_node("Label")

func _physics_process(delta):
	label.set_text(str(Item.inv_ammo[Item.current_inventory_slot]))
