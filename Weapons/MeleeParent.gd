extends Node2D

var SwooshParticles = preload("res://Weapons/SwooshParticles.tscn")

# Gun information
var swing_cooldown = 10 # Amount of time between each shot
var swoosh_time = 1
var automatic = false
var damage = 15
var attack_speed = 1

# Screen shake variables
var duration = 0.2
var frequency = 15
var amplitude = 4
var priority = 0

# Misc
var is_swinging = false
var has_hit = false
var current_arm = "right"

func _ready():
	pass

func _physics_process(delta):
	input()

func input():
	if automatic == true:
		if Input.is_action_pressed("shoot") and not is_swinging and not Item.using_menu:
			swing()
	else:
		if Input.is_action_just_pressed("shoot") and not is_swinging and not Item.using_menu:
			swing()

func swing():
	is_swinging = true
	$AnimationPlayer.set_speed_scale(attack_speed)
	if current_arm == "right":
		current_arm = "left"
		play_player_arm_swing(false)
		$AnimationPlayer.play("swingleft")
	elif current_arm == "left":
		current_arm = "right"
		play_player_arm_swing(true)
		$AnimationPlayer.play("swingright")
		
	get_node("CoolDownTimer").set_wait_time(swing_cooldown)
	get_node("CoolDownTimer").start()
	spawn_swoosh_particles()
	
func play_player_arm_swing(flipped):
	var arm_anim_player = get_parent().get_parent().get_node("ArmAnimPlayer")
	arm_anim_player.set_speed_scale(3)
	get_parent().get_parent().get_node("Arms").set_flip_h(flipped)
	arm_anim_player.play("meleeswing")

func spawn_swoosh_particles():
	var particles = SwooshParticles.instance()
	particles.set_up(swing_cooldown)
	particles.set_emitting(true)
	get_node("Sprite").get_node("SwooshPos").add_child(particles)
	
func swing_anim_finished():
	if current_arm == "right":
		get_node("Sprite").set_flip_h(false)
	elif current_arm == "left":
		get_node("Sprite").set_flip_h(true)
	has_hit = false
		
func swing_cooldown_finished():
	is_swinging = false
