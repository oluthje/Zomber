extends Node2D

# Gun information
var hit_cooldown = 10 # Amount of time between each shot
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
var current_arm = "right"

func _ready():
	pass

func _physics_process(delta):
	input()

func input():
	if automatic == true:
		if Input.is_action_pressed("shoot") and not is_swinging:
			swing()
	else:
		if Input.is_action_just_pressed("shoot") and not is_swinging:
			swing()

func swing():
	$AnimationPlayer.set_speed_scale(attack_speed)
	if current_arm == "right":
		current_arm = "left"
		$AnimationPlayer.play("swingleft")
	elif current_arm == "left":
		current_arm = "right"
		$AnimationPlayer.play("swingright")
	
func swing_finished():
	if current_arm == "right":
		get_node("Sprite").set_flip_h(false)
	elif current_arm == "left":
		get_node("Sprite").set_flip_h(true)
