extends KinematicBody2D

var Corpse = preload("res://Enemies/Gore/Corpse.tscn")

# Guns
var Pistol = preload("res://Weapons/Pistol.tscn")

# Movement
var speed = 150
var friction = 0.18
var acceleration = 0.5
var velocity = Vector2.ZERO

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
	
func _on_Area2D_body_entered(body):
	if "Zombie" in body.name:
		take_damage()
