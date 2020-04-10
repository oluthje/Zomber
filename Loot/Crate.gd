extends Area2D

var SmokeEffect = preload("res://Environment/SmokeEffect.tscn")
var PhysicalItem = preload("res://Weapons/PhysicalItem.tscn")

var broken = false

func _on_Crate_body_entered(body):
	if "Player" in body.name and not broken:
		broken = true
		open_crate()

func open_crate():
	var smoke = SmokeEffect.instance()
	smoke.set_global_position(get_global_position())
	get_parent().add_child(smoke)
	$AnimationPlayer.play("break")
	$Particles2D.set_emitting(true)
	set_rand_rotation()
	spawn_physical_item(Item.get_loot_drop())
	
func spawn_physical_item(item_name):
	var item = PhysicalItem.instance()
	item.set_global_position(get_global_position())
	item.set_up_item(item_name, -1)
	get_parent().add_child(item)

func set_rand_rotation():
	randomize()
	var rand_rot = rand_range(0, 90)
	set_rotation(deg2rad(rand_rot))
