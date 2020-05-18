extends KinematicBody2D

var RequiredMaterialsPopup = preload("res://Construction/RequiredMaterialsNode.tscn")
var SoundEffectPlayer = preload("res://SoundEffectPlayer.tscn")
var state = "crashed"
var required_materials = {
	Item.ENGINE: 1
#	Item.SPARK_PLUG: 1,
#	Item.FUEL: 1,
#	Item.REPAIR_KIT: 1
}
var player_in_car = false
var enter_cooldown_time = 0.5

func _ready():
	if state == "crashed":
		$AnimationPlayer.play("crashed")
		get_node("Sparks").set_emitting(true)
		spawn_required_materials_popup()

func _physics_process(delta):
	check_for_player_adding_resource()
	
	if Input.is_action_just_pressed("interact") and player_in_car:
		exit_humvee()
#	if Input.is_action_pressed("up")

func exit_humvee():
	var pos = get_global_position()
	player_in_car = false
	get_node("EnterCooldownTimer").set_wait_time(enter_cooldown_time)
	get_node("EnterCooldownTimer").start()
	get_parent().spawn_saved_player(Vector2(pos.x, pos.y + 24))
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
	popup.set_position(Vector2(-8, -32))
	popup.setup(required_materials)
	add_child(popup)

func _on_CollectPlayerArea_body_entered(body):
	if "Player" in body.name:
		player_in_car = true
		$DoorAnimPlayer.play_backwards("open_door")
		get_node("CollectPlayerArea").call_deferred("set_monitoring", false)
		get_parent().remove_player()
		
func _on_EnterCooldownTimer_timeout():
	get_node("CollectPlayerArea").call_deferred("set_monitoring", true)
