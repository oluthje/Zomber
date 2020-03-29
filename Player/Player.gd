extends KinematicBody2D

onready var pickup_timer = get_node("PickupTimer")

var PhysicalItem = preload("res://Weapons/PhysicalItem.tscn")
var Corpse = preload("res://Enemies/Gore/Corpse.tscn")

# Guns
var Pistol = preload("res://Weapons/Pistol.tscn")

# Melee weapons
var Axe = preload("res://Weapons/Axe.tscn")

# Movement
var speed = 150
var friction = 0.18
var acceleration = 0.5
var velocity = Vector2.ZERO

# Misc
var can_pickup = true
var pickup_cooldown = 0.2
var pickupable_item_area

func _ready():
	try_update_held_item()

func _physics_process(delta):
	if Item.player_should_update_held_item:
		try_update_held_item()
		Item.player_should_update_held_item = false
	rotate(get_rotation_toward_mouse())
	get_input()
	
	get_parent().player_pos = get_global_position()
	
func get_rotation_toward_mouse():
	var mouse_pos = get_global_mouse_position()
	var angle = get_angle_to(mouse_pos)

	return angle
	
func take_damage():
	spawn_corpse()
	queue_free()
	
func spawn_corpse():
	var corpse = Corpse.instance()
	corpse.set_global_position(get_global_position())
	corpse.set_rotation(get_global_rotation() - deg2rad(180))
	corpse.set_up("player")
	get_parent().add_child(corpse)

func get_input():
	var input_velocity = Vector2.ZERO
	try_to_pickup_item()
	rotate_legs_toward_movement()
	
	if Input.is_action_pressed('right'):
		input_velocity.x += 1
	if Input.is_action_pressed('left'):
		input_velocity.x -= 1
	if Input.is_action_pressed('down'):
		input_velocity.y += 1
	if Input.is_action_pressed('up'):
		input_velocity.y -= 1
	input_velocity = input_velocity.normalized() * speed
	
	# If there's input, accelerate to the input velocity
	if input_velocity.length() > 0:
		$AnimationPlayer.play("Walk")
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)

func rotate_legs_toward_movement():
	var legs_anim = get_node("Legs")
	var angle = get_angle_to(velocity + get_global_position())
	legs_anim.set_rotation(angle + deg2rad(90))
	
func try_to_pickup_item():
	var ammo_num_to_item
	if Input.is_action_pressed("interact"):
		#print("pickupable_item_area: " + str(pickupable_item_area.name))
		if can_pickup and Item.item_player_can_pick_up != "":
			pickup_timer.set_wait_time(pickup_cooldown)
			can_pickup = false
			
			# Get current loaded ammo num for item drop
			ammo_num_to_item = Item.inv_ammo[Item.current_inventory_slot]
			
			try_to_slot_item(ammo_num_to_item)
			try_update_held_item()

func try_to_slot_item(ammo_to_item):
	var could_slot_item = false
	var slot_placed_item
	var item = pickupable_item_area
		
	if Item.inventory[Item.current_inventory_slot] == Item.EMPTY:
		Item.inventory[Item.current_inventory_slot] = Item.item_player_can_pick_up
		slot_placed_item = Item.current_inventory_slot
	else:
		for index in len(Item.inventory):
			if Item.inventory[index] == Item.EMPTY and could_slot_item == false:
				Item.inventory[index] = Item.item_player_can_pick_up
				slot_placed_item = index
				could_slot_item = true
			index += 1
		# If item could not be slotted in an empty slot, then replace current item with new item
		if not could_slot_item:
			slot_placed_item = Item.current_inventory_slot
			drop_held_item(ammo_to_item)
			
	pickupable_item_area.queue_free()
				
	# Get ammo from item, then delete item to be picked up
#	if "PhysicalItem" in pickupable_item_area.name:
#		if item.item_name == Item.item_player_can_pick_up:
#			if item.item_type != Item.MELEE:
#				if item.item_type == Item.PROJECTILE:
#					Item.inv_ammo[slot_placed_item] = item.ammo_count
#				elif item.item_type == Item.ITEM:
#					if Item.inv_ammo[slot_placed_item] == -1:
#						Item.inv_ammo[slot_placed_item] += item.ammo_count + 1
#					else:
#						Item.inv_ammo[slot_placed_item] += item.ammo_count
					
func drop_held_item(ammo):
	var physical_item = PhysicalItem.instance()
	get_parent().add_child(physical_item)
	physical_item.set_global_position(get_global_position())
	physical_item.set_up_item(Item.inventory[Item.current_inventory_slot])
	
	Item.inv_ammo[Item.current_inventory_slot] = -1
	Item.inventory[Item.current_inventory_slot] = Item.item_player_can_pick_up

func try_update_held_item():
	Item.should_update_inventory = true
	
	if get_node("HandHeldItem").get_children().size() > 0:
		for child in get_node("HandHeldItem").get_children():
			child.queue_free()
	
	if Item.inventory[Item.current_inventory_slot] == Item.EMPTY:
		pass
	elif Item.inventory[Item.current_inventory_slot] == Item.PISTOL:
		var item = Pistol.instance()
		get_node("HandHeldItem").add_child(item)
	elif Item.inventory[Item.current_inventory_slot] == Item.AXE:
		var item = Axe.instance()
		get_node("HandHeldItem").add_child(item)
	
func _on_Area2D_body_entered(body):
	if "Zombie" in body.name:
		take_damage()

func _on_PickupTimer_timeout():
	can_pickup = true
