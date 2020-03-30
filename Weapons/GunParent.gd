extends Node2D

var Bullet = preload("res://Weapons/Bullet.tscn")

# Gun information
var shot_cooldown = 10 # Amount of time between each shot
var automatic = true
var reload_time
var loaded_ammo = 0  # Some value before reload system is in
var reload_amount = 0 # Amount that the gun gets when reloaded
var dispersion = 0 # The degree range that the bullet could possible go toward. (degrees)
var bullet_speed = 180
var bullet_damage = 15

# Screen shake variables
var duration = 0.2
var frequency = 15
var amplitude = 4
var priority = 0

# Misc
var first_ready = true
var time = 0
var is_reloading = false

func _ready():
	if Item.inv_ammo[Item.current_inventory_slot] != -1:
		loaded_ammo = Item.inv_ammo[Item.current_inventory_slot]
	
	if not first_ready:
		Item.inv_ammo[Item.current_inventory_slot] = loaded_ammo
	
	first_ready = false
	
func _physics_process(delta):
	time += 1
	input()

func shake_screen():
	get_parent().get_parent().get_node("Camera2D").get_node("ScreenShake").start(duration, frequency, amplitude, priority)
	
func input():
	var should_save_loaded_ammo = false
	
	if automatic == true:
		if Input.is_action_pressed("shoot") and time > shot_cooldown and is_reloading != true and loaded_ammo > 0 and not Item.using_menu:
			shoot()
			should_save_loaded_ammo = true
	else:
		if Input.is_action_just_pressed("shoot") and time > shot_cooldown and is_reloading != true and loaded_ammo > 0 and not Item.using_menu:
			shoot()
			should_save_loaded_ammo = true

	if Input.is_action_pressed("reload") and loaded_ammo != reload_amount:
		is_reloading = true
		$AnimationPlayer.play("reload")
		
	#Item.loaded_ammo = loaded_ammo  # Tell Scene script total current ammo count for this weapon
	if should_save_loaded_ammo:
		save_loaded_ammo()
	
func save_loaded_ammo():
	Item.inv_ammo[Item.current_inventory_slot] = loaded_ammo
	
func shoot():
	shake_screen()
	spawn_bullet()
	$AnimationPlayer.play("shoot")
	loaded_ammo -= 1
	time = 0 

func spawn_bullet():
	var bullet = Bullet.instance()
	bullet.set_global_position(get_node("BulletPos").global_position)
	bullet.set_up(get_global_rotation() + get_added_dispersion(), bullet_speed, bullet_damage)
	get_parent().get_parent().get_parent().add_child(bullet)

func get_added_dispersion():
	if dispersion > 0:
		randomize()
		var added_bullet_rot = rand_range(0, dispersion/2)
		randomize()
		var rand_num = rand_range(0, 1)
		if rand_num == 0:
			added_bullet_rot = added_bullet_rot * -1
		return deg2rad(added_bullet_rot)
	else:
		return 0

func reload_code():
	if is_reloading:
		while loaded_ammo < reload_amount:
			loaded_ammo += 1
		is_reloading = false
		save_loaded_ammo()
