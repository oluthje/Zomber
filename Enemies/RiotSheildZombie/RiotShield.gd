extends Node2D

#var Corpse = preload("res://Enemies/Gore/Corpse.tscn")

var shield_health = 100

func take_damage(damage):
	shield_health -= damage
	$AnimationPlayer.play("shieldhit")
	if shield_health <= 0:
		get_parent().speed = 75
		get_parent().walk_anim_speed = 1
		get_parent().lost_shield = true
		get_parent().replace_with_zombie()
		spawn_dropped_shield()
		queue_free()

func spawn_dropped_shield():
	var corpse = get_parent().Corpse.instance()
	corpse.set_global_position(get_global_position())
	corpse.set_rotation(get_global_rotation() - deg2rad(90))
	corpse.set_up("riotshield")
	get_parent().get_parent().add_child(corpse)
