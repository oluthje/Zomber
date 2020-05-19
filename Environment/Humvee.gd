extends KinematicBody2D

var RequiredMaterialsPopup = preload("res://Construction/RequiredMaterialsNode.tscn")
var SoundEffectPlayer = preload("res://SoundEffectPlayer.tscn")

var state = "crashed"
var required_materials = {
	Item.ENGINE: 1,
	Item.SPARK_PLUG: 1,
	Item.FUEL: 1,
	Item.REPAIR_KIT: 1
}
var player_in_car = false
var enter_cooldown_time = 0.5

# Driving
var speed = 250
var friction = 0.035
var acceleration = 0.05
var velocity = Vector2.ZERO
var steering_speed = 2
var steering_friction = 0.15
var steering_accel = 0.05
var steering = Vector2.ZERO

func _ready():
	if state == "crashed":
		$AnimationPlayer.play("crashed")
		get_node("Sparks").set_emitting(true)
		spawn_required_materials_popup()

func _physics_process(delta):
	check_for_player_adding_resource()
	get_driving_input()

func get_driving_input():
	var input_velocity = Vector2.ZERO
	var input_steering = Vector2.ZERO

	if player_in_car:
		if Input.is_action_just_pressed("interact"):
			exit_humvee()
		if Input.is_action_pressed('right'):
			input_steering.x += 1
		if Input.is_action_pressed('left'):
			input_steering.x -= 1
		if Input.is_action_pressed('down'):
			input_velocity.x += 1
		if Input.is_action_pressed('up'):
			input_velocity.x -= 1
	input_velocity = input_velocity.rotated(rotation)
	input_velocity = input_velocity.normalized() * speed
	input_steering = input_steering.normalized() * steering_speed * get_percent_speed()
	
	# Steering
	if input_steering.length() > 0:
		steering = steering.linear_interpolate(input_steering, steering_accel)
	else:
		steering = steering.linear_interpolate(Vector2.ZERO, steering_friction)
	rotate(deg2rad(steering.x))

	# Driving
	if input_velocity.length() > 0:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)
	
	
	set_wheel_rotations()
	
func set_wheel_rotations():
	var wheel_rots = [0, 180]
	var wheels = get_node("FrontWheels").get_children()
	var percent_steering = steering.x/steering_speed
	var max_wheel_rot = 45
	
	for index in wheels.size():
		wheels[index].set_rotation(deg2rad(wheel_rots[index] + (max_wheel_rot * percent_steering)))
	
	get_node("Label").set_text(str(steering))

func get_percent_speed():
	var current_speed = Vector2(0, 0).distance_to(velocity)
	var percent_speed = current_speed/speed
	return percent_speed

func exit_humvee():
	var pos = get_position()
	player_in_car = false
	get_node("EnterCooldownTimer").set_wait_time(enter_cooldown_time)
	get_node("EnterCooldownTimer").start()
	get_parent().get_node("Camera2D").get_node("AnimationPlayer").play_backwards("zoom_out")
	get_parent().spawn_saved_player(get_global_position() + Vector2(-32, 24).rotated(rotation))
	$DoorAnimPlayer.play("open_door")

func spawn_sound_effect_player(sound):
	var player = SoundEffectPlayer.instance()
	player.set_global_position(get_global_position())
	player.setup(sound, 5)
	get_parent().add_child(player)

func check_for_player_adding_resource():
	var bodies = get_node("CollectPartsArea").get_overlapping_bodies()
	for body in bodies:
		if "Player" in body.name:
			if body.carrying_object:
				if requires_part(body.object_carrying_name):
					add_part(body.object_carrying_name)
					body.get_node("CarryableObject").get_node("SlotItemImage").select_item_to_display("none")
					body.carrying_object = false
					body.object_carrying_name = ""
					body.try_update_held_item()

func add_part(part):
	spawn_sound_effect_player(Item.ADDED_RESOURCE)
	required_materials[part] -= 1
	if part == Item.ENGINE:
		get_node("Engine").set_visible(true)
	
	if has_all_parts():
		get_node("Engine").set_visible(false)
		get_node("Sparks").set_emitting(false)
		$DoorAnimPlayer.play("open_door")
		$AnimationPlayer.play("fixed")

func has_all_parts():
	for part in required_materials:
		if required_materials[part] == 1:
			return false
	return true

func requires_part(resource):
	if required_materials.has(resource):
		if required_materials[resource] > 0:
			return true
	return false

func spawn_required_materials_popup():
	var popup = RequiredMaterialsPopup.instance()
	popup.set_position(Vector2(-32, -32))
	popup.setup(required_materials)
	add_child(popup)

func _on_CollectPlayerArea_body_entered(body):
	if "Player" in body.name:
		player_in_car = true
		$DoorAnimPlayer.play_backwards("open_door")
		get_node("CollectPlayerArea").call_deferred("set_monitoring", false)
		get_parent().get_node("Camera2D").get_node("AnimationPlayer").play("zoom_out")
		get_parent().remove_player()
		
func _on_EnterCooldownTimer_timeout():
	get_node("CollectPlayerArea").call_deferred("set_monitoring", true)
