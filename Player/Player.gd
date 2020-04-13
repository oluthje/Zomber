extends KinematicBody2D

onready var pickup_timer = get_node("PickupTimer")

var CarryableObject = preload("res://Environment/CarryableObject.tscn")
var PhysicalItem = preload("res://Weapons/PhysicalItem.tscn")
var Corpse = preload("res://Enemies/Gore/Corpse.tscn")
var BloodSplat = preload("res://Enemies/Gore/Bloodsplat.tscn")
var BloodSplatter = preload("res://Enemies/Gore/Bloodsplatter.tscn")

# Guns
var Pistol = preload("res://Weapons/Pistol.tscn")
var Shotgun = preload("res://Weapons/Shotgun.tscn")

# Melee weapons
var Axe = preload("res://Weapons/Axe.tscn")
var Pickaxe = preload("res://Weapons/Pickaxe.tscn")

# Movement
var speed = 150
var friction = 0.18
var acceleration = 0.5
var velocity = Vector2.ZERO
var enemy_pos = Vector2()
var knock_back_dir = 0
var knocked_back = false
var knock_back_amount = 1
var knock_back_num = 0

# Object pickup
var carrying_object = false
var pickupable_object_area
var object_carrying_name = ""

# Item pickup
var can_pickup = true
var pickup_cooldown = 0.2
var pickupable_item_area

# Misc
var can_take_damage = true

var god_mode = false
func _ready():
	try_update_held_item()
	
	if god_mode:
		speed = 500
		$CollisionShape2D.disabled = true

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

func take_damage(damage, dir):
	if can_take_damage:
		$AnimationPlayer.play("take_damage")
		can_take_damage = false
		knocked_back = true
		knock_back_dir = dir
		knock_back_num = knock_back_amount
		Item.player_health -= 1
		spawn_blood_splatter()
	if Item.player_health <= 0:
		spawn_corpse()
		spawn_blood_splat()
		spawn_blood_splatter()
		queue_free()
	
func spawn_blood_splatter():
	var blood_splatter = BloodSplatter.instance()
	blood_splatter.set_rotation(knock_back_dir)
	blood_splatter.set_global_position(get_global_position())
	get_parent().add_child(blood_splatter)
	
func spawn_blood_splat():
	randomize()
	var rand_rot = rand_range(0, 360)
	var blood_splat = BloodSplat.instance()
	blood_splat.set_rotation(deg2rad(rand_rot))
	blood_splat.set_global_position(get_global_position())
	get_parent().add_child(blood_splat)

func spawn_corpse():
	var corpse = Corpse.instance()
	corpse.set_global_position(get_global_position())
	corpse.set_rotation(knock_back_dir + deg2rad(90))
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
		$LegAnimPlayer.play("Walk")
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	elif knocked_back:
		input_velocity = Vector2(-200, 0).rotated(knock_back_dir)
		if knock_back_num <= 0.5:
			knocked_back = false
		input_velocity = -input_velocity
		input_velocity = input_velocity.linear_interpolate(Vector2.ZERO, friction)
		velocity = (input_velocity.normalized() * speed * knock_back_num)
		knock_back_num -= 0.2
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)

func rotate_legs_toward_movement():
	var legs_anim = get_node("Legs")
	var angle = get_angle_to(velocity + get_global_position())
	legs_anim.set_rotation(angle + deg2rad(90))

func try_to_pickup_item():
	var ammo_num_to_item
	if Input.is_action_just_pressed("interact") and not carrying_object:
		if can_pickup and Item.object_player_can_pick_up != "":
			pickup_timer.set_wait_time(pickup_cooldown)
			pickup_timer.start()
			can_pickup = false
			
			try_pickup_object()
			try_update_held_item()
		elif can_pickup and Item.item_player_can_pick_up != "":
			pickup_timer.set_wait_time(pickup_cooldown)
			pickup_timer.start()
			can_pickup = false
			
			# Get current loaded ammo num for item drop
			ammo_num_to_item = Item.inv_ammo[Item.current_inventory_slot]
			
			try_to_slot_item(ammo_num_to_item)
			try_update_held_item()
	elif Input.is_action_just_pressed("interact") and carrying_object:
		try_drop_object()
	
func try_pickup_object():
	carrying_object = true
	Item.object_player_can_pick_up = ""
	pickupable_object_area.queue_free()
	object_carrying_name = pickupable_object_area.object_name
	get_node("CarryableObject").get_node("SlotItemImage").select_item_to_display(object_carrying_name)

func try_drop_object():
	var carryable_object = CarryableObject.instance()
	carryable_object.set_up_object(object_carrying_name)
	carryable_object.set_global_position(get_global_position())
	carryable_object.set_rotation(get_rotation())
	get_parent().add_child(carryable_object)
	
	get_node("CarryableObject").get_node("SlotItemImage").select_item_to_display("none")
	carrying_object = false
	object_carrying_name = ""
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
				
	Item.inv_ammo[slot_placed_item] = item.ammo_count
	
func drop_held_item(ammo):
	var physical_item = PhysicalItem.instance()
	get_parent().add_child(physical_item)
	physical_item.set_global_position(get_global_position())
	physical_item.set_up_item(Item.inventory[Item.current_inventory_slot], ammo)
	
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
	elif Item.inventory[Item.current_inventory_slot] == Item.SHOTGUN:
		var item = Shotgun.instance()
		get_node("HandHeldItem").add_child(item)
	elif Item.inventory[Item.current_inventory_slot] == Item.AXE:
		var item = Axe.instance()
		get_node("HandHeldItem").add_child(item)
	elif Item.inventory[Item.current_inventory_slot] == Item.PICKAXE:
		var item = Pickaxe.instance()
		get_node("HandHeldItem").add_child(item)
	
	if carrying_object:
		if get_node("HandHeldItem").get_children().size() > 0:
			for child in get_node("HandHeldItem").get_children():
				child.queue_free()

#func _on_Area2D_body_entered(body):
#	#if "Zombie" in body.name:
#	if 
#		enemy_pos = body.get_global_position()
#		var rot_to_body = get_angle_to(enemy_pos)
#		take_damage(100, rot_to_body)
		
func _on_Area2D_area_entered(area):
	if area.is_in_group("damageplayer"):
		enemy_pos = area.get_global_position()
		var rot_to_body = get_angle_to(enemy_pos)
		take_damage(100, rot_to_body)

func _on_PickupTimer_timeout():
	can_pickup = true

func _on_AnimationPlayer_animation_finished(anim_name):
	can_take_damage = true
