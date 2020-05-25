extends Node2D

var SoundEffectPlayer = preload("res://SoundEffectPlayer.tscn")

# Item information
var shot_cooldown = 10
var automatic = true
var ammo = 1
var use_sound

# Misc
var first_ready = true
var time = 0

func _ready():
	get_parent().get_parent().get_node("ArmAnimPlayer").play("shootpos")
	if Item.inv_ammo[Item.current_inventory_slot] != -1:
		ammo = Item.inv_ammo[Item.current_inventory_slot]
	
	if not first_ready:
		Item.inv_ammo[Item.current_inventory_slot] = ammo
	
	first_ready = false
	
func _physics_process(delta):
	time += 1
	input()
	
func input():
	var should_save_loaded_ammo = false
	
	if automatic == true:
		if Input.is_action_pressed("shoot") and ammo > 0 and not Item.using_menu:
			use()
			should_save_loaded_ammo = true
	else:
		if Input.is_action_just_pressed("shoot") and ammo > 0 and not Item.using_menu:
			print("tried shoot")
			use()
			should_save_loaded_ammo = true
	
	if should_save_loaded_ammo:
		save_loaded_ammo()

func save_loaded_ammo():
	Item.inv_ammo[Item.current_inventory_slot] = ammo

func use():
	spawn_sound_effect_player(use_sound)
	jerk_ammo_count_hud("down")
	ammo -= 1
	time = 0

func spawn_sound_effect_player(sound):
	var player = SoundEffectPlayer.instance()
	player.set_global_position(get_global_position())
	player.setup(sound, 5)
	get_parent().get_parent().get_parent().add_child(player)
	
func jerk_ammo_count_hud(dir):
	get_ammo_hud_node().jerk_ammo_label(dir)
	
func get_ammo_hud_node():
	var game_node
	for child in get_tree().get_root().get_node("Main").get_children():
		if "Game" in child.name:
			game_node = child
	
	return game_node.get_node("CanvasLayer").get_node("WeaponInfo")
