extends Node2D

var InventorySlot = preload("res://HUD/InventorySlot.tscn")

var slot_num = 0
var current_slot = 0

func _ready():
	draw_inventory()
	
func _physics_process(delta):
	input()
	if Item.should_update_inventory == true:
		draw_inventory()
		Item.should_update_inventory = false
	
func draw_inventory():
	for i in get_children():
		i.queue_free()
		
	# Loads new health HUD
	var container_x = 0
	slot_num = 0
	
	# Get total num of slots
	for slot_item in Item.inventory:
		if slot_item != Item.DISABLED:
			slot_num += 1
		
	for i in range(slot_num):
		var inventory_slot = InventorySlot.instance()
		add_child(inventory_slot)
		container_x = i*32
		inventory_slot.position = Vector2(container_x + 16, 284)
		
		# If this new slot being loaded bas an item in it, then create an image of it in slot
		if Item.inventory[i] != Item.EMPTY:
			inventory_slot.get_node("SlotItemImage").select_item_to_display(Item.inventory[i])
		
		# If this slot is currently selected, then make it look selected
		if i == current_slot:
			inventory_slot.get_node("AnimationPlayer").play("selected")
			
func input():
	var change_made = false
	
	# Controller input
	if Input.is_action_just_pressed("shift_slot"):
		current_slot += 1
		change_made = true

	# Keyboard input
	if Input.is_action_just_pressed("pressed_1"):
		current_slot = 0
		change_made = true
	if Input.is_action_just_pressed("pressed_2"):
		current_slot = 1
		change_made = true
	if Input.is_action_just_pressed("pressed_3"):
		current_slot = 2
		change_made = true
	if Input.is_action_just_pressed("pressed_4"):
		current_slot = 3
		change_made = true
	if Input.is_action_just_pressed("pressed_5"):
		current_slot = 4
		change_made = true
	if Input.is_action_just_pressed("pressed_6"):
		current_slot = 5
		change_made = true
		
	if current_slot >= slot_num:
		current_slot = 0
	elif current_slot < 0:
		current_slot = slot_num - 1
	
	if Item.current_inventory_slot != current_slot:
		Item.player_should_update_held_item = true
	Item.current_inventory_slot = current_slot
		
	if change_made == true:
		draw_inventory()
