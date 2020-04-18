extends Area2D

var SmokeEffect = preload("res://Environment/SmokeEffect.tscn")
var PhysicalItem = preload("res://Weapons/PhysicalItem.tscn")

var broken = false

func _ready():
	spawn_smoke_effect()

func open_crate():
	spawn_smoke_effect()
	$AnimationPlayer.play("break")
	$Particles2D.set_emitting(true)
	set_rand_rotation()
	spawn_physical_item(Item.get_loot_drop(get_tier_by_wavenum()))
	
func spawn_smoke_effect():
	for i in range(2):
		randomize()
		var rand_x = rand_range(0, 24)
		if flipped_heads():
			rand_x = -rand_x
		randomize()
		var rand_y = rand_range(0, 24)
		if flipped_heads():
			rand_y = -rand_y
		
		var smoke = SmokeEffect.instance()
		smoke.set_global_position(Vector2(get_global_position().x + rand_x, get_global_position().y + rand_y))
		get_parent().add_child(smoke)
		
func flipped_heads():
	randomize()
	var rand_num = rand_range(0, 100)
	if rand_num < 50:
		return true
	return false

func get_tier_by_wavenum():
	if Item.wave_num > 9:
		return 3
	if Item.wave_num > 4:
		return 2
	return 1

func spawn_physical_item(item_name):
	var item = PhysicalItem.instance()
	item.set_global_position(get_global_position())
	item.set_up_item(item_name, -1)
	get_parent().add_child(item)

func set_rand_rotation():
	randomize()
	var rand_rot = rand_range(0, 90)
	set_rotation(deg2rad(rand_rot))

func _on_Crate_body_entered(body):
	if "Player" in body.name and not broken:
		broken = true
		open_crate()

func _on_AnimationPlayer_animation_finished(anim_name):
	if broken:
		get_node("Timer").start()

func _on_Timer_timeout():
	queue_free()
