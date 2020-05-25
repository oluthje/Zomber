extends "res://Loot/PlayerItemParent.gd"

func _ready():
	# Item information
	shot_cooldown = 10
	automatic = false
	ammo = 1
	use_sound = Item.CORPSE_FALL
	._ready()

func use():
	$AnimationPlayer.play("inject")
	ammo -= 1
	time = 0

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "inject":
		pass
