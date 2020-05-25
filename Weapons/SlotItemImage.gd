extends Node2D

func select_item_to_display(item):
	if $AnimationPlayer.get_animation(item) != null:
		#print("found in animplayer: " + str(item))
		if item != Item.STIM_SHOT:
			get_node("Sprite").set_visible(true)
		$AnimationPlayer.play(item)
		return
	$AnimatedSprite.play(item)
	get_node("Sprite").set_visible(false)
