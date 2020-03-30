extends AnimatedSprite

func _ready():
	pass

func set_up(resource):
	$AnimationPlayer.play(resource)
